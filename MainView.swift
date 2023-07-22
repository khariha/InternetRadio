//  ContentView.swift
//  InternetRadio
//
//  Created by Kishore Hariharan on 7/17/23.
//

import SwiftUI

import SwiftUI

struct ContentView: View {
    
    init() {
            //Use this if NavigationBarTitle is with Large Font
            UINavigationBar.appearance().largeTitleTextAttributes = [.font : UIFont(name: "Righteous-Regular", size: 46)!]

            //Use this if NavigationBarTitle is with displayMode = .inline
            //UINavigationBar.appearance().titleTextAttributes = [.font : UIFont(name: "Georgia-Bold", size: 20)!]
        }
    
    var body: some View {
        NavigationStack {
            VStack{
                RadioView()
                    .navigationTitle(Text("GlobeTuner"))
                    .padding(.leading, 10)
                    .padding(.trailing, 10)
            }
        }
        
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

