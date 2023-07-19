//
//  RadioPlayingNowView.swift
//  InternetRadio
//
//  Created by Kishore Hariharan on 7/18/23.
//

import Foundation
import SwiftUI

struct RadioPlayingNowView: View {
    @ObservedObject var api = RadioBrowserAPI.shared
    
    var playingStation: RadioStation? {
        api.stations.first { $0.stationuuid == api.playingStationID }
    }
    
    var body: some View {
        ZStack(alignment: .leading){
            HStack{
                if let station = playingStation {
                    VStack(alignment: .leading, spacing: 0){
                        Text("Now Playing: \(station.name)")
                            .fontWeight(.bold)
                        Text(station.country)
                    }
                } else {
                    
                }
                Spacer()
            }
        }
    }
}


struct RadioPlayingNowView_Previews: PreviewProvider {
    static var previews: some View {
        RadioPlayingNowView().preferredColorScheme(.dark)
    }
}
