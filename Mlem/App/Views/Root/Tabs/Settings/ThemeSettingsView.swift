//
//  ThemeSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 11/05/2024.
//

import SwiftUI

struct ThemeSettingsView: View {
    @Setting(\.appearance_interfaceStyle) var interfaceStyle
    @Setting(\.appearance_palette) var colorPalette
    
    // convenience
    var supportedModes: UIUserInterfaceStyle { colorPalette.supportedModes }
    
    var body: some View {
        Form {
            Section {
                // When a single-mode theme is selected, the picker will _display_ that mode as selected but not actually change the settings value
                // so that it reverts the the actual settings value when a multi-mode theme is selected
                Picker("Style", selection: supportedModes == .unspecified ? $interfaceStyle : .constant(supportedModes)) {
                    ForEach(UIUserInterfaceStyle.optionCases, id: \.self) { style in
                        interfaceStyleLabel(for: style)
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
                .labelStyle(.titleAndIcon)
            }
            .labelsHidden()
            .pickerStyle(.inline)
        }
                .labelStyle(.conditional)
        .toggleStyle(.conditional)
        .navigationTitle("Theme")
    }
    
    @ViewBuilder
    func interfaceStyleLabel(for style: UIUserInterfaceStyle) -> some View {
        Label(style.label, icon: style.icon)
            .foregroundStyle(
                supportedModes == .unspecified || supportedModes == style
                    ? .themedPrimary
                    : .themedSecondary
            )
    }
}
