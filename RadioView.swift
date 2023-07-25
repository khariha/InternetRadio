//  RadioView.swift
//  InternetRadio
//
//  Created by Kishore Hariharan on 7/17/23.
//

import SwiftUI
import AVKit
import Kingfisher

class SelectedStationModel: ObservableObject {
    static let shared = SelectedStationModel()
    @Published var selectedStation: RadioStation?
    
}

struct RadioView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject var api = RadioBrowserAPI.shared
    @ObservedObject var favoritesAPI = globalFavoritesAPI
    
    @State private var selectedCountry: String = "US" {
        didSet {
            api.getRequestOfRadioStations(for: selectedCountry)
        }
    }
    @State private var searchText = ""
    @State var scaleRotate = false
    @ObservedObject var selectedStationAPI = SelectedStationModel.shared
    
    init() {
        api.getRequestOfRadioStations(for: selectedCountry)
    }
    
    private var filteredStations: [RadioStation] {
        let radioStations = api.stations
        if searchText.isEmpty {
            return radioStations.sorted(by: { $0.votes > $1.votes })
        } else {
            return radioStations.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }.sorted(by: { $0.votes > $1.votes })
        }
    }
    
    private func playOrPauseStation(_ station: RadioStation) {
        if api.playingStationID == station.stationuuid {
            if api.isPlaying {
                api.pauseRadio()
            } else {
                api.playRadio(urlString: station.url_resolved, stationId: station.stationuuid)
                selectedStationAPI.selectedStation = station
            }
        } else {
            api.playRadio(urlString: station.url_resolved, stationId: station.stationuuid)
            selectedStationAPI.selectedStation = station
        }
    }
    
    private func toggleFavorite(_ station: RadioStation) {
        if favoritesAPI.isFavorite(station: station) {
            favoritesAPI.removeFavorite(station: station)
        } else {
            favoritesAPI.addFavorite(station: station)
        }
    }
    
    var body: some View {
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
                        .animation(Animation.interpolatingSpring(stiffness: 60, damping: 13).repeatForever(autoreverses: true), value: scaleRotate)
                        .padding(.bottom, 50)
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
                                        Image(systemName: "antenna.radiowaves.left.and.right")
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
                                    .foregroundColor(selectedStationAPI.selectedStation?.stationuuid == station.stationuuid ? .indigo : (colorScheme == .dark ? .white : .black))
                                Text(station.state ?? "")
                                    .foregroundColor(selectedStationAPI.selectedStation?.stationuuid == station.stationuuid ? .indigo : (colorScheme == .dark ? .white : .black))
                            }
                            
                            Spacer()  // This will push the button to the right
                            
                            Button(action: { playOrPauseStation(station) }) {
                                Image(systemName: api.playingStationID == station.stationuuid && api.isPlaying ? "pause.fill" : "play.fill")
                                    .foregroundColor(.indigo)
                            }
                            .buttonStyle(.bordered)
                            .buttonBorderShape(.roundedRectangle)
                            
                            Button(action: { toggleFavorite(station) }) {
                                Image(systemName: favoritesAPI.isFavorite(station: station) ? "bookmark.fill" : "bookmark")
                                    .foregroundColor(.indigo)
                                //.animation(.interpolatingSpring(stiffness: 170, damping: 15))
                            }
                            .buttonStyle(.bordered)
                            .buttonBorderShape(.roundedRectangle)
                        }
                        .onTapGesture {
                            withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.6, blendDuration: 0.6)) {
                                playOrPauseStation(station)
                            }
                        }
                        .listRowBackground(selectedStationAPI.selectedStation?.stationuuid == station.stationuuid ? GlassBackground(width: 350, height: 60, color: .indigo).cornerRadius(10)
                            .cornerRadius(10) : nil)
                        .listRowSeparator(.hidden)
                        
                    }
                    .listStyle(.inset)
                    .scrollIndicators(.hidden)
                    .contentShape(Rectangle())
                    .mask(LinearGradient(gradient: Gradient(stops: [
                                .init(color: .black, location: 0.85),
                                .init(color: .clear, location: 1)
                            ]), startPoint: .top, endPoint: .bottom))
                    
                case let .failure(error):
                    Text(error.localizedDescription)
                }
            }
        }
        .searchable(text: $searchText)
        .toolbar {
            NavigationLink(destination: SettingsView()) {
                Image(systemName: "gearshape.fill")
            }
        }
        .background(
            Image("homeBackground2")
                .ignoresSafeArea()
                .padding(.bottom, 600)
        )
    }
}

struct RadioView_Previews: PreviewProvider {
    static var previews: some View {
        RadioView()
    }
}
