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
    @Dependency(\.palette) var palette
    
    @AppStorage("colorPalette") var colorPalette: Palette = .standard {
        didSet {
            palette.changePalette(to: colorPalette)
        }
    }
    
    var body: some View {
        Button("Monochrome") {
            colorPalette = .monochrome
        }
        
        Button("Default") {
            colorPalette = .standard
        }
    }
}
