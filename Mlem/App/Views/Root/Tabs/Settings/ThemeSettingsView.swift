//
//  ThemeSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 11/05/2024.
//

import SwiftUI

struct ThemeSettingsView: View {
    @Environment(Palette.self) var palette
    
    @Setting(\.interfaceStyle) var interfaceStyle
    @Setting(\.colorPalette) var colorPalette
    
    var body: some View {
        PaletteForm {
            Picker("Style", selection: $interfaceStyle) {
                Text("System").tag(UIUserInterfaceStyle.unspecified)
                Text("Light").tag(UIUserInterfaceStyle.light)
                Text("Dark").tag(UIUserInterfaceStyle.dark)
            }
            .labelsHidden()
            .pickerStyle(.inline)
            
            Picker("Theme", selection: $colorPalette) {
                ForEach(PaletteOption.allCases, id: \.rawValue) { item in
                    ThemeLabel(palette: item)
                        .tag(item)
                }
            }
            .labelsHidden()
            .pickerStyle(.inline)
        }
        .onChange(of: colorPalette) {
            palette.changePalette(to: colorPalette)
        }
    }
}
