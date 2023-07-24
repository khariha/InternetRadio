//
//  RadioBrowserAPI.swift
//  InternetRadio
//
//  Created by Kishore Hariharan on 7/17/23.
//

import Foundation
import AVKit

class RadioBrowserAPI: NSObject, ObservableObject, AVPlayerItemMetadataOutputPushDelegate {
    
    static let shared = RadioBrowserAPI()
    
    @Published var stations = [RadioStation]()
    @Published var isPlaying = false
    @Published var nowPlayingItem: String = ""
    
    var player: AVPlayer?
    var playingStationID: String?
    
    private var metadataOutput: AVPlayerItemMetadataOutput!
    
    private override init() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
        } catch(let error) {
            print(error.localizedDescription)
        }
    }
    
    func resolve(hostname: String) -> String? {
        let host = CFHostCreateWithName(nil, hostname as CFString).takeRetainedValue()
        CFHostStartInfoResolution(host, .addresses, nil)
        var success: DarwinBoolean = false
        if let addresses = CFHostGetAddressing(host, &success)?.takeUnretainedValue() as NSArray?,
           let theAddress = addresses.firstObject as? NSData {
            var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
            if getnameinfo(theAddress.bytes.assumingMemoryBound(to: sockaddr.self), socklen_t(theAddress.length),
                           &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST) == 0 {
                let numAddress = String(cString: hostname)
                return numAddress
            }
        }
        return nil
    }
    
    func reverseDNS(ip: String) -> String {
        var results: UnsafeMutablePointer<addrinfo>? = nil
        defer {
            if let results = results {
                freeaddrinfo(results)
            }
        }
        let error = getaddrinfo(ip, nil, nil, &results)
        if (error != 0) {
            print("Unable to reverse ip: \(ip)")
            return ip
        }
        
        for addrinfo in sequence(first: results, next: { $0?.pointee.ai_next }) {
            guard let pointee = addrinfo?.pointee else {
                print("Unable to reverse ip: \(ip)")
                return ip
            }
            
            let hname = UnsafeMutablePointer<Int8>.allocate(capacity: Int(NI_MAXHOST))
            defer {
                hname.deallocate()
            }
            let error = getnameinfo(pointee.ai_addr, pointee.ai_addrlen, hname, socklen_t(NI_MAXHOST), nil, 0, 0)
            if (error != 0) {
                continue
            }
            return String(cString: hname)
        }
        
        return ip
    }
    
    enum RadioRequestResult<Success> {
        case empty
        case inProgress
        case success(Success)
        case failure(Error)
    }
    
    enum RadioPlayResult {
        case empty
        case inProgress
        case success
        case failure
    }
    
    @Published var radioResult: RadioRequestResult<[RadioStation]> = .empty
    @Published var radioRequestResult: RadioPlayResult = .empty
    
    func getRequestOfRadioStations(for countryCode: String) {
        
        self.radioResult = .inProgress
        
        let urlString = String("https://" + reverseDNS(ip: resolve(hostname: "all.api.radio-browser.info") ?? "at1.api.radio-browser.info") + "/json/stations/bycountrycodeexact/\(countryCode)")
        print(urlString)
        guard let url = URL(string: urlString) else {
            print("Invalid URL string: \(urlString)")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                print("DataTask error: \(error?.localizedDescription ?? "unknown error")")
                return
            }
            print(data)
            do {
                let decoder = JSONDecoder()
                let radioStations = try decoder.decode([RadioStation].self, from: data)
                DispatchQueue.main.async {
                    if data.count < 10 {
                        self.radioResult = .empty
                    } else {
                        self.radioResult = .success(radioStations)
                        self.stations = radioStations
                    }
                    
                }
            } catch let error as DecodingError {
                if case .dataCorrupted = error {
                    print("Decoding error: \(error). Falling back to default API.")
                    self.fallbackToDefaultAPI()
                } else {
                    print("Other decoding error: \(error)")
                }
            } catch let error {
                print("Non-decoding error: \(error)")
            }
            
            
        }
        
        task.resume()
        
    }
    
    func fallbackToDefaultAPI() {
        let urlString = "https://nl1.api.radio-browser.info/json/stations/bycountrycodeexact/us"
        guard let url = URL(string: urlString) else {
            print("Invalid URL string: \(urlString)")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                print("DataTask error: \(error?.localizedDescription ?? "unknown error")")
                return
            }
            print(data)
            do {
                let decoder = JSONDecoder()
                let radioStations = try decoder.decode([RadioStation].self, from: data)
                DispatchQueue.main.async {
                    self.stations = radioStations
                }
            } catch let error {
                print("Decoding error: \(error)")
            }
        }
        
        task.resume()
    }
    
    
    
    func playRadio(urlString: String, stationId: String) {  // Changed from UUID to String
        
        // Set radioRequestResult to .inProgress
        DispatchQueue.main.async {
            self.radioRequestResult = .inProgress
        }
        
        guard let url = URL(string: urlString) else {
            return
        }
        print(url)
        
        let playerItem = AVPlayerItem(url: url)
        metadataOutput = AVPlayerItemMetadataOutput(identifiers: nil)
        metadataOutput.setDelegate(self, queue: DispatchQueue.main)
        playerItem.add(metadataOutput)
        
        self.player = AVPlayer(playerItem: playerItem)
        
        // Observe the status of the player item
        self.player?.currentItem?.addObserver(self, forKeyPath: "status", options: [.new, .initial], context: nil)
        
        self.player?.play()
        self.isPlaying = true
        self.playingStationID = stationId // Update the currently playing station ID
    }
    
    // Observe value changes
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "status" {
            switch self.player?.currentItem?.status {
            case .readyToPlay:
                DispatchQueue.main.async {
                    self.radioRequestResult = .success
                }
            case .failed:
                if let error = self.player?.currentItem?.error as NSError?, error.domain == NSURLErrorDomain && error.code == NSURLErrorTimedOut {
                    DispatchQueue.main.async {
                        self.radioRequestResult = .failure
                    }
                } else {
                    DispatchQueue.main.async {
                        self.radioRequestResult = .failure
                    }
                }
            case .unknown, .none:
                self.radioRequestResult = .inProgress
            @unknown default:
                DispatchQueue.main.async {
                    self.radioRequestResult = .failure
                }
            }
        }
    }
    
    deinit {
        self.player?.currentItem?.removeObserver(self, forKeyPath: "status")
    }
    
    
    func pauseRadio() {
        player?.pause()
        isPlaying = false
        // Do not clear the currently playing station ID when paused
    }
    
    func metadataOutput(_ output: AVPlayerItemMetadataOutput, didOutputTimedMetadataGroups groups: [AVTimedMetadataGroup], from track: AVPlayerItemTrack?) {
        if let item = groups.first?.items.first // make this an AVMetadata item
        {
            item.value(forKeyPath: "value") // looking for that key bro
            let Song = (item.value(forKeyPath: "value")!)
            nowPlayingItem = Song as! String
            print("Now Playing: \n \(Song)") // print the results
        } else {
            nowPlayingItem = "MetaData Error"
            print("MetaData Error") // No Metadata or Could not read
        }
    }
    
}

struct RadioStation: Codable, Identifiable {
    let id = UUID()
    let changeuuid: String
    let stationuuid: String
    let serveruuid: String?
    let name: String
    let url: String
    let url_resolved: String
    let homepage: String
    let favicon: String?
    let tags: String?
    let country: String
    let countrycode: String
    let state: String?
    let language: String?
    let votes: Int
    let codec: String?
    let bitrate: Int
    let lastcheckok: Int
    let clickcount: Int
    let clicktrend: Int
    // Optional fields
    let iso_3166_2: String?
    let languagecodes: String?
    let lastchangetime: String?
    let lastchangetime_iso8601: String?
    let hls: Int?
    let lastchecktime: String?
    let lastchecktime_iso8601: String?
    let lastcheckoktime: String?
    let lastcheckoktime_iso8601: String?
    let lastlocalchecktime: String?
    let lastlocalchecktime_iso8601: String?
    let clicktimestamp: String?
    let clicktimestamp_iso8601: String?
    let ssl_error: Int?
    let geo_lat: Double?
    let geo_long: Double?
    let has_extended_info: Bool?
    
    // Computed property for the play image name
    var playImageName: String {
        return RadioBrowserAPI.shared.playingStationID == stationuuid ? "pause.fill" : "play.fill"
    }
    
}






