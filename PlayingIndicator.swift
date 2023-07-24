//
//  PlayingIndicator.swift
//  InternetRadio
//
//  Created by Kishore Hariharan on 7/24/23.
//

import Foundation
import SwiftUI

struct PlayingIndicator: View {
    @State private var barHeights = [CGFloat](repeating: 0.0, count: 5)
    private let timer = Timer.publish(every: 0.3, on: .main, in: .common).autoconnect()
    
    var body: some View {
        HStack(spacing: 1) {
            ForEach(0..<5) { index in
                Rectangle()
                    .fill(Color.indigo)
                    .frame(width: 1, height: self.barHeights[index])
                    .animation(.easeInOut(duration: 0.5))
            }
        }
        .onReceive(timer) { _ in
            self.barHeights = self.barHeights.map { _ in CGFloat.random(in: 1...20) }
        }
        .frame(width: 20, height: 20)
    }
}


