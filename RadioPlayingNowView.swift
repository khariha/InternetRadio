//  RadioPlayingNowView.swift
//  InternetRadio
//
//  Created by Kishore Hariharan on 7/18/23.
//

import Foundation
import SwiftUI
import Kingfisher
import Combine

struct RadioPlayingNowView: View {
    @ObservedObject var api = RadioBrowserAPI.shared
    @ObservedObject var favoritesAPI = globalFavoritesAPI
    @State private var selectedCountry: String = "US"
    
    var playingStation: RadioStation? {
        api.stations.first { $0.stationuuid == api.playingStationID }
    }
    
    var body: some View {
        
        let radioStations: [RadioStation] = api.stations
        
        VStack {
            ZStack(alignment: .center) {
                Rectangle()
                    .frame(width: 350, height: 110)
                    .foregroundColor(.indigo)
                    .cornerRadius(10)
                
                VStack {
                    HStack {
                        if playingStation != nil {
                            if let faviconUrl = URL(string: playingStation?.favicon ?? "") {
                                KFImage(faviconUrl)
                                    .resizable()
                                    .placeholder {
                                        Image(systemName: "antenna.radiowaves.left.and.right.circle.fill")

                                    }
                                    .frame(width: 30, height: 30)
                                    .cornerRadius(50)
                                    .aspectRatio(contentMode: .fit)
                                    .clipped()
                            } else {
                                Image(systemName: "antenna.radiowaves.left.and.right.circle.fill")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .cornerRadius(50)
                                    .aspectRatio(contentMode: .fit)
                                    .clipped()
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 0) {
                            Text("\(playingStation?.name ?? "Select a station to play")")
                                .fontWeight(.bold)
                                .font(.system(size: 16))
                                .lineLimit(1)
                                .foregroundColor(.white)

                            Text(playingStation?.state?.isEmpty == true ? "Unknown" : (playingStation?.state ?? "or shuffle for a random station"))
                                .fontWeight(.light)
                                .font(.system(size: 14))
                                .lineLimit(1)
                                .foregroundColor(.white)
                        }

                        
                        Spacer()
                        
                        HStack {
                            Button(action: {
                                if let station = playingStation {
                                    if api.isPlaying {
                                        api.pauseRadio()
                                    } else {
                                        api.playRadio(urlString: station.url_resolved, stationId: station.stationuuid)
                                    }
                                }
                            }) {
                                Image(systemName: api.isPlaying ? "pause.fill" : "play.fill")
                                    .foregroundColor(.white)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                            
                            Button {
                                if let randomStation = radioStations.randomElement() {
                                    api.playRadio(urlString: randomStation.url, stationId: randomStation.stationuuid)
                                }
                            } label: {
                                Image(systemName: "shuffle")
                                    .foregroundColor(.white)
                            }
                            
                            Button {
                                if let station = playingStation {
                                    if favoritesAPI.isFavorite(station: station) {
                                        favoritesAPI.removeFavorite(station: station)
                                    } else {
                                        favoritesAPI.addFavorite(station: station)
                                    }
                                }
                            } label: {
                                if let station = playingStation {
                                    Image(systemName: favoritesAPI.isFavorite(station: station) ? "bookmark.fill" : "bookmark")
                                        .foregroundColor(.white)
                                } else {
                                    Image(systemName: "bookmark")
                                        .foregroundColor(.white)
                                }
                            }
                            .buttonStyle(BorderlessButtonStyle())
                            
                        }
                        .padding(.trailing, 30)
                    }
                    .padding(.leading, 30)
                    .padding(.top, 5)
                    
                    HStack {
                        CountryPickerView(selectedCountry: $selectedCountry)
                            .onChange(of: selectedCountry) { newValue in
                                api.getRequestOfRadioStations(for: newValue)
                            }
                        
                        NavigationLink(destination: FavoritesView()) {
                            ZStack {
                                Rectangle()
                                    .frame(width: 125, height: 30)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                
                                HStack {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.indigo)
                                    Text("Favorites")
                                        .foregroundColor(.indigo)
                                }
                            }
                        }
                    }
                    .padding(.top, 5)
                }
            }
        }
    }
}

struct RadioPlayingNowView_Previews: PreviewProvider {
    static var previews: some View {
        RadioPlayingNowView()
    }
}
