//  BookmarkView.swift
//  InternetRadio
//
//  Created by Kishore Hariharan on 7/18/23.
//

import SwiftUI
import Foundation

let globalFavoritesAPI = FavoriteRadioStation()
let stationIDKey = "stationID_key"

struct FavoritesView: View {
    @ObservedObject var api = RadioBrowserAPI.shared
    @ObservedObject var favoritesAPI = globalFavoritesAPI
    
    var body: some View {
        List(favoritesAPI.favoriteStations) { station in
            HStack {
                VStack(alignment: .leading) {
                    Text(station.name.trimmingCharacters(in: .whitespacesAndNewlines))
                        .fontWeight(.bold)
                    Text(station.state ?? "")
                }
                Spacer()
                
                Button(action: { playOrPause(station) }) {
                    Image(systemName: api.playingStationID == station.stationuuid ? "pause.fill" : "play.fill")
                        .foregroundColor(.blue)
                }
                .buttonStyle(BorderlessButtonStyle())
                
                Button(action: { toggleFavorite(station) }) {
                    Image(systemName: favoritesAPI.isFavorite(station: station) ? "bookmark.fill" : "bookmark")
                }
                .buttonStyle(BorderlessButtonStyle())
            }
        }
    }
    
    func playOrPause(_ station: RadioStation) {
        if api.playingStationID == station.stationuuid {
            api.pauseRadio()
        } else {
            api.playRadio(urlString: station.url_resolved, stationId: station.stationuuid)
            print(station.url_resolved)
        }
    }
    
    func toggleFavorite(_ station: RadioStation) {
        if favoritesAPI.isFavorite(station: station) {
            favoritesAPI.removeFavorite(station: station)
        } else {
            favoritesAPI.addFavorite(station: station)
        }
    }
}

class FavoriteRadioStation: ObservableObject {
    @Published var favoriteStationIDs: [String] = [] {
        didSet {
            UserDefaults.standard.set(favoriteStationIDs, forKey: stationIDKey)
        }
    }
    
    let api = RadioBrowserAPI.shared
    
    init() {
        if let savedIDs = UserDefaults.standard.array(forKey: stationIDKey) as? [String] {
            favoriteStationIDs = savedIDs
        }
    }
    
    var favoriteStations: [RadioStation] {
        api.stations.filter { favoriteStationIDs.contains($0.stationuuid) }
    }
    
    func addFavorite(station: RadioStation) {
        favoriteStationIDs.append(station.stationuuid)
    }
    
    func removeFavorite(station: RadioStation) {
        favoriteStationIDs.removeAll(where: { $0 == station.stationuuid })
    }
    
    func isFavorite(station: RadioStation) -> Bool {
        favoriteStationIDs.contains(station.stationuuid)
    }
}

struct FavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesView()
    }
}
