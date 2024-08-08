//
//  ThemeSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 11/05/2024.
//

import SwiftUI

struct ThemeSettingsView: View {
    @Setting(\.colorPalette) var colorPalette
    @Environment(Palette.self) var palette
    
    var body: some View {
        Form {
            Picker("Theme", selection: $colorPalette) {
                ForEach(PaletteOption.allCases, id: \.rawValue) { item in
                    Text(item.label)
                        .tag(item)
                }
            }
            .pickerStyle(.inline)
        }
        .onChange(of: colorPalette) {
            palette.changePalette(to: colorPalette)
        }
    }
}
