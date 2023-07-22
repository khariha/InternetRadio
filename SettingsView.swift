//
//  SettingsView.swift
//  InternetRadio
//
//  Created by Kishore Hariharan on 7/22/23.
//

import SwiftUI

struct SettingsView: View {
    
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some View {
        NavigationView {
            List {
                HStack {
                    Toggle("Dark Mode", isOn: $isDarkMode)
                }
            }
        }
        .navigationTitle("Settings")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
