//  RadioPlayingNowView.swift
//  InternetRadio
//
//  Created by Kishore Hariharan on 7/18/23.
//

import Foundation
import SwiftUI
import Kingfisher
import Combine
import MarqueeText

struct RadioPlayingNowView: View {
    @ObservedObject var api = RadioBrowserAPI.shared
    @ObservedObject var favoritesAPI = globalFavoritesAPI
    @State private var selectedCountry: String = "US"
    @ObservedObject var selectedStationAPI = SelectedStationModel.shared

    private var playingStation: RadioStation? {
        api.stations.first { $0.stationuuid == api.playingStationID }
    }

    private var radioStations: [RadioStation] {
        api.stations
    }

    private func togglePlayOrPause() {
        if let station = playingStation {
            if api.isPlaying {
                api.pauseRadio()
            } else {
                api.playRadio(urlString: station.url_resolved, stationId: station.stationuuid)
            }
        }
    }

    private func playRandomStation() {
        if let randomStation = radioStations.randomElement() {
            api.playRadio(urlString: randomStation.url_resolved, stationId: randomStation.stationuuid)
            selectedStationAPI.selectedStation = randomStation
        }
    }

    private func toggleFavorite() {
        if let station = playingStation {
            if favoritesAPI.isFavorite(station: station) {
                favoritesAPI.removeFavorite(station: station)
            } else {
                favoritesAPI.addFavorite(station: station)
            }
        }
    }

    var body: some View {
        VStack {
            ZStack(alignment: .center) {
                GlassBackground(width: 350, height: 110, color: .indigo)
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
                            MarqueeText(text: "\(playingStation?.name ?? "Select a station to play")", font: UIFont.preferredFont(forTextStyle: .subheadline), leftFade: 16, rightFade: 16, startDelay: 3)
                                .fontWeight(.bold)
                                .font(.system(size: 16))
                                .lineLimit(1)
                                .foregroundColor(.white)
                            
                            
                            Text(playingStation?.state?.isEmpty == true ? "Unknown" : playingStation?.state ?? "or shuffle for a random station")
                                .fontWeight(.light)
                                .font(.system(size: 14))
                                .lineLimit(1)
                                .foregroundColor(.white)

                        }
                        
                        Spacer()
                        
                        HStack {
                            Button(action: togglePlayOrPause) {
                                Image(systemName: api.isPlaying ? "pause.fill" : "play.fill")
                                    .foregroundColor(.indigo)
                            }
                            .buttonStyle(.bordered)
                            .buttonBorderShape(.roundedRectangle)
                            
                            Button(action: playRandomStation) {
                                Image(systemName: "shuffle")
                                    .foregroundColor(.indigo)
                            }
                            .buttonStyle(.bordered)
                            .buttonBorderShape(.roundedRectangle)
                            
                            Button(action: toggleFavorite) {
                                if let station = playingStation {
                                    Image(systemName: favoritesAPI.isFavorite(station: station) ? "bookmark.fill" : "bookmark")
                                        .foregroundColor(.indigo)
                                } else {
                                    Image(systemName: "bookmark")
                                        .foregroundColor(.indigo)
                                }
                            }
                            .buttonStyle(.bordered)
                            .buttonBorderShape(.roundedRectangle)
                            
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
