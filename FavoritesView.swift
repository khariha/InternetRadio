//
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
            HStack{
                VStack(alignment: .leading) {
                    Text(station.name.trimmingCharacters(in: .whitespacesAndNewlines))
                        .fontWeight(.bold)
                    Text(station.state ?? "")
                }
                Spacer()  // This will push the button to the right
                Button(action: {
                    if api.playingStationID == station.stationuuid {
                        api.pauseRadio()
                    } else {
                        api.playRadio(urlString: station.url, stationId: station.stationuuid)
                    }
                }) {
                    Image(systemName: api.playingStationID == station.stationuuid ? "pause.fill" : "play.fill")
                        .foregroundColor(.blue)
                }
                .buttonStyle(BorderlessButtonStyle())
                Button(action: {
                    if favoritesAPI.isFavorite(station: station) {
                        favoritesAPI.removeFavorite(station: station)
                    } else {
                        favoritesAPI.addFavorite(station: station)
                    }
                }) {
                    Image(systemName: favoritesAPI.isFavorite(station: station) ? "bookmark.fill" : "bookmark")
                }
                .buttonStyle(BorderlessButtonStyle())
            }
        }
    }
}

class FavoriteRadioStation: ObservableObject {
    
    @Published var favoriteStationIDs: [String] = [] {
        didSet {
            saveFavoriteIDs()
        }
    }
    
    let api = RadioBrowserAPI.shared  // Access to all stations
    
    // Initialization
    init() {
        loadFavoriteIDs()
    }
    
    // Computed property to get favorite stations
    var favoriteStations: [RadioStation] {
        api.stations.filter { favoriteStationIDs.contains($0.stationuuid) }
    }
    
    func addFavorite(station: RadioStation) {
        favoriteStationIDs.append(station.stationuuid)
    }
    
    func removeFavorite(station: RadioStation) {
        guard let index = favoriteStationIDs.firstIndex(of: station.stationuuid) else { return  }
        favoriteStationIDs.remove(at: index)
    }
    
    func isFavorite(station: RadioStation) -> Bool {
        return favoriteStationIDs.contains(station.stationuuid)
    }
    
    func saveFavoriteIDs() { //UserDefaults persistence
        UserDefaults.standard.set(favoriteStationIDs, forKey: stationIDKey)
    }
    
    func loadFavoriteIDs() { //Load persisted data
        if let savedIDs = UserDefaults.standard.array(forKey: stationIDKey) as? [String] {
            favoriteStationIDs = savedIDs
        }
    }
}




struct FavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesView().preferredColorScheme(.dark)
    }
}
