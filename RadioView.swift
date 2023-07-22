//  RadioView.swift
//  InternetRadio
//
//  Created by Kishore Hariharan on 7/17/23.
//

import SwiftUI
import AVKit
import Kingfisher

struct RadioView: View {
    
    @ObservedObject var api = RadioBrowserAPI.shared
    @ObservedObject var favoritesAPI = globalFavoritesAPI
    @State private var selectedCountry: String = "US" {
        didSet {
            api.getRequestOfRadioStations(for: selectedCountry)
        }
    }
    
    
    @State private var searchText = ""
    @State var isFavorite : Bool = false
    
    @State var scaleRotate = false
    
    init() {
        api.getRequestOfRadioStations(for: selectedCountry)
    }
    
    var body: some View {
        
        let radioStations: [RadioStation] = api.stations
        var filteredStations: [RadioStation] {
            if searchText.isEmpty {
                return radioStations.sorted(by: { $0.votes > $1.votes })
            } else {
                return radioStations.filter { station in
                    station.name.localizedCaseInsensitiveContains(searchText)
                }.sorted(by: { $0.votes > $1.votes })
            }
        }
        
        GeometryReader { geometry in
            VStack(spacing: 0) {
                RadioPlayingNowView()
                    .padding(.bottom, 20)
                
                switch api.radioResult {
                case .empty:
                    
                    Text("No stations in this country to fetch. 🥲")
                        .foregroundColor(.indigo)
                        .fontWeight(.light)
                    
                case .inProgress:
                    Spacer()
                    Image(systemName: "dot.radiowaves.left.and.right")
                        .foregroundColor(.indigo)
                        .scaleEffect(scaleRotate ? 2.5 : 2)
                        .rotationEffect(.degrees(scaleRotate ? 360 : 0), anchor: .center)
                        .animation(Animation.interpolatingSpring(stiffness: 60, damping: 13).repeatForever(autoreverses: true))
                        .padding(.bottom, 50)
                    //.animation(Animation.easeInOut(duration: 2).delay(0.5).repeatForever(autoreverses: true))
                        .onAppear() {
                        self.scaleRotate.toggle()
                    }
                    Text("Fetching Stations...")
                        .foregroundColor(.indigo)
                    Spacer()
                    
                case .success(_):
                    List(filteredStations.filter { !$0.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) { station in
                        HStack {
                            if let faviconUrl = URL(string: station.favicon ?? "") {
                                KFImage(faviconUrl)
                                    .resizable()
                                    .placeholder {
                                        ProgressView()
                                    }
                                    .frame(width: 30, height: 30)
                                    .cornerRadius(50)
                                    .aspectRatio(contentMode: .fit)
                                    .clipped()
                            } else {
                                Image(systemName: "antenna.radiowaves.left.and.right")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .cornerRadius(50)
                                    .aspectRatio(contentMode: .fit)
                                    .clipped()
                            }
                            
                            VStack(alignment: .leading) {
                                Text(station.name.trimmingCharacters(in: .whitespacesAndNewlines))
                                    .fontWeight(.bold)
                                Text(station.state ?? "")
                            }
                            Spacer()  // This will push the button to the right
                            
                            Button(action: {
                                if api.playingStationID == station.stationuuid {
                                    if api.isPlaying {
                                        api.pauseRadio()
                                    } else {
                                        api.playRadio(urlString: station.url, stationId: station.stationuuid)
                                    }
                                } else {
                                    api.playRadio(urlString: station.url, stationId: station.stationuuid)
                                }
                            }) {
                                Image(systemName: api.playingStationID == station.stationuuid && api.isPlaying ? "pause.fill" : "play.fill")
                                    .foregroundColor(.indigo)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                            
                            Button {
                                if favoritesAPI.isFavorite(station: station) {
                                    favoritesAPI.removeFavorite(station: station)
                                } else {
                                    favoritesAPI.addFavorite(station: station)
                                }
                            } label: {
                                Image(systemName: favoritesAPI.isFavorite(station: station) ? "bookmark.fill" : "bookmark")
                                    .foregroundColor(.indigo)
                                    //.animation(.interpolatingSpring(stiffness: 170, damping: 15))
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        }
                    }
                    .listStyle(.inset)
                   
                    
                case let .failure(error):
                    Text(error.localizedDescription)
                }
            }
        }
        .searchable(text: $searchText)
    }
}

struct RadioView_Previews: PreviewProvider {
    static var previews: some View {
        RadioView().preferredColorScheme(.dark)
    }
}
