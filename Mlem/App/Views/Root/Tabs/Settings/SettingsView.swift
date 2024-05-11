//
//  SettingsView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-05-09.
//

import Dependencies
import Foundation
import SwiftUI

struct SettingsView: View {
    @Environment(Palette.self) var palette
    
    @AppStorage("colorPalette") var colorPalette: PaletteOption = .standard {
        didSet {
            print("updating palette to \(colorPalette)")
            palette.changePalette(to: colorPalette)
        }
    }
    
    var body: some View {
        Form {
            colorSettings
        }
    }
    
    var colorSettings: some View {
        Section {
            Button("Default") {
                colorPalette = .standard
            }
            
            Button("Monochrome") {
                colorPalette = .monochrome
            }
        } header: {
            Text("Theme")
        }
    }
}
