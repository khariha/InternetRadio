//
//  CountryPickerView.swift
//  InternetRadio
//
//  Created by Kishore Hariharan on 7/20/23.
//

import Foundation
import SwiftUI

struct Country {
    var id: String
    var name: String
}

struct CountryPickerView: View {
    
    @Binding var selectedCountry: String
    
    var body: some View {
        ZStack{
            Rectangle()
                .frame(width: 215, height: 30)
                .foregroundColor(.white)
                .cornerRadius(10)
            HStack{
                Text(flag(country: selectedCountry))
                Picker("Country", selection: $selectedCountry) {
                    ForEach(getLocales(), id: \.id) { country in
                        Text(country.name).tag(country.id)
                            .lineLimit(1)
                    }
                }
            }
            
        }
        
    }
    
    func getLocales() -> [Country] {
        var locales = Locale.isoRegionCodes
            .filter { $0 != "US"}
            .compactMap { Country(id: $0, name: Locale.current.localizedString(forRegionCode: $0) ?? $0)}
        locales.sort { $0.name < $1.name }  // Sort locales in alphabetical order
        let unitedStates = Country(id: "US", name: Locale.current.localizedString(forRegionCode: "US") ?? "United States")
        if let usIndex = locales.firstIndex(where: { $0.name == unitedStates.name }) {
            locales.remove(at: usIndex)
        }
        return [unitedStates] + locales
    }

    
    func flag(country:String) -> String {
        let base : UInt32 = 127397
        var s = ""
        for v in country.unicodeScalars {
            s.unicodeScalars.append(UnicodeScalar(base + v.value)!)
        }
        return String(s)
    }
    
    func returnCountryCode() -> String {
        return selectedCountry
    }
}
