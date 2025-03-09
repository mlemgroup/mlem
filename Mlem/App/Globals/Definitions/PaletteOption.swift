//
//  PaletteOption.swift
//  Mlem
//
//  Created by Sjmarf on 2025-03-08.
//

import Foundation
import SwiftUI
import Theming

enum PaletteOption: String, CaseIterable, Codable {
    case standard, oled, monochrome, solarized, dracula
    
    var palette: Palette {
        switch self {
        case .standard: .default
        case .oled: .oled
        case .monochrome: .monochrome
        case .solarized: .solarized
        case .dracula: .dracula
        }
    }
    
    var label: LocalizedStringResource {
        switch self {
        case .standard: "Default"
        case .oled: "OLED"
        case .monochrome: "Monochrome"
        case .solarized: "Solarized"
        case .dracula: "Dracula"
        }
    }
    
    var supportedModes: UIUserInterfaceStyle {
        switch self {
        case .oled, .dracula: .dark
        default: .unspecified
        }
    }
}
