//  ContentView.swift
//  InternetRadio
//
//  Created by Kishore Hariharan on 7/17/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            RadioView()
                .navigationTitle("InternetRadio")
                .toolbar {
                    ToolbarItem {
                        NavigationLink(destination: FavoritesView()) {
                            favoritesButton
                        }
                    }
                }
        }
    }
    
    var favoritesButton: some View {
        HStack{
            Image(systemName: "heart.fill")
                .foregroundColor(.white)
            Text("Favorites")
                .foregroundColor(.white)
                .fontWeight(.bold)
        }
        .frame(width: 135, height: 30)
        .background(Color.accentColor)
        .cornerRadius(10)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().preferredColorScheme(.dark)
    }
}
