//
//  Glassmorphism.swift
//  InternetRadio
//
//  Created by Kishore Hariharan on 7/23/23.
//

import Foundation
import SwiftUI

struct GlassBackground: View {

    let width: CGFloat
    let height: CGFloat
    let color: Color

    var body: some View {
        ZStack{
            RadialGradient(colors: [.clear, color],
                           center: .center,
                           startRadius: 1,
                           endRadius: 100)
                .opacity(0.6)
            Rectangle().foregroundColor(color)
        }
        .opacity(0.2)
        .blur(radius: 2)
        .cornerRadius(10)
        .frame(width: width, height: height)
    }
}
