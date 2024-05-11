//
//  ThemeSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 11/05/2024.
//

import SwiftUI

struct ThemeSettingsView: View {
    @AppStorage("colorPalette") var colorPalette: PaletteOption = .standard {
        didSet {
            print("updating palette to \(colorPalette)")
            palette.changePalette(to: colorPalette)
        }
    }
    
    @Environment(Palette.self) var palette
    
    var body: some View {
        Form {
            Picker("Theme", selection: $colorPalette) {
                ForEach(PaletteOption.allCases, id: \.rawValue) { item in
                    Text(item.rawValue)
                }
            }
            .pickerStyle(.inline)
        }
    }
}
