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
    
    @State private var searchText = ""
    @State var isFavorite : Bool = false
    
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
            VStack{
                RadioPlayingNowView()
                    .padding(.top, 10)
                    .padding(.leading, 30)
                List(filteredStations.filter { !$0.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) { station in
                    HStack{
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
                                api.pauseRadio()
                            } else {
                                api.playRadio(urlString: station.url, stationId: station.stationuuid)
                            }
                        }) {
                            Image(systemName: api.playingStationID == station.stationuuid ? "pause.fill" : "play.fill")
                                .foregroundColor(.blue)
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
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        
                    }
                }
                .listStyle(.insetGrouped)
                .searchable(text: $searchText)
                .onAppear {
                    api.getRequestOfRadioStations()
                }
            }
        }
    }
}

struct RadioView_Previews: PreviewProvider {
    static var previews: some View {
        RadioView().preferredColorScheme(.dark)
    }
}
