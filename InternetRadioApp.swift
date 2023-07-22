//
//  InternetRadioApp.swift
//  InternetRadio
//
//  Created by Kishore Hariharan on 7/17/23.
//

import SwiftUI

@main
struct InternetRadioApp: App {
    
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some Scene {
        WindowGroup {
            ContentView().preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }
}
