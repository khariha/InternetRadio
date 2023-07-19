//
//  BookmarkView.swift
//  InternetRadio
//
//  Created by Kishore Hariharan on 7/18/23.
//

import SwiftUI

let globalFavoritesAPI = FavoriteRadioStation()

struct FavoritesView: View {
    @ObservedObject var api = RadioBrowserAPI.shared
    @ObservedObject var favoritesAPI = globalFavoritesAPI

    var body: some View {
        List(favoritesAPI.favoriteStations) { station in
            HStack{
                VStack(alignment: .leading) {
                    Text(station.name.trimmingCharacters(in: .whitespacesAndNewlines))
                        .fontWeight(.bold)
                    Text(station.country)
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
    @Published var favoriteStationIDs = Set<String>()
    
    let api = RadioBrowserAPI.shared  // Access to all stations

    // Computed property to get favorite stations
    var favoriteStations: [RadioStation] {
        api.stations.filter { favoriteStationIDs.contains($0.stationuuid) }
    }

    func addFavorite(station: RadioStation) {
        favoriteStationIDs.insert(station.stationuuid)
    }

    func removeFavorite(station: RadioStation) {
        favoriteStationIDs.remove(station.stationuuid)
    }

    func isFavorite(station: RadioStation) -> Bool {
        return favoriteStationIDs.contains(station.stationuuid)
    }
}


struct FavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesView().preferredColorScheme(.dark)
    }
}
