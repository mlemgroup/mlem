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
    
    // convenience
    var supportedModes: UIUserInterfaceStyle { colorPalette.palette.supportedModes }
    
    var body: some View {
        Form {
            Section {
                // When a single-mode theme is selected, the picker will _display_ that mode as selected but not actually change the settings value
                // so that it reverts the the actual settings value when a multi-mode theme is selected
                Picker("Style", selection: supportedModes == .unspecified ? $interfaceStyle : .constant(supportedModes)) {
                    ForEach(UIUserInterfaceStyle.optionCases, id: \.self) { style in
                        Text(style.label)
                            .foregroundStyle(
                                supportedModes == .unspecified || supportedModes == style
                                    ? palette.primary
                                    : palette.secondary
                            )
                    }
                }
                .labelsHidden()
                .pickerStyle(.inline)
            } footer: {
                if supportedModes != .unspecified {
                    Text("The \(colorPalette.label) theme only supports \(supportedModes.label.lowercased()) mode.")
                }
            }
            
            Picker("Theme", selection: $colorPalette) {
                ForEach(PaletteOption.allCases, id: \.rawValue) { item in
                    ThemeLabel(palette: item)
                        .tag(item)
                }
            }
            .labelsHidden()
            .pickerStyle(.inline)
        }
    }
}
