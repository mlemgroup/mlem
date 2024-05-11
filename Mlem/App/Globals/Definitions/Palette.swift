//
//  ColorProvider.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-05-06.
//

import Foundation
import SwiftUI

protocol PaletteProviding {
    // basics
    var primary: Color { get }
    var background: Color { get }
    var secondaryBackground: Color { get }
    var tertiaryBackground: Color { get }
    var accent: Color { get }
    
    // interactions
    var upvote: Color { get }
    var downvote: Color { get }
    var save: Color { get }
}

enum PaletteOption: String {
    case standard, monochrome
    
    var palette: ColorPalette {
        switch self {
        case .standard: ColorPalette.standard
        case .monochrome: ColorPalette.monochrome
        }
    }
}

struct ColorPalette: PaletteProviding {
    // basics
    var primary: Color
    var background: Color
    var secondaryBackground: Color
    var tertiaryBackground: Color
    var accent: Color

    // interactions
    var upvote: Color
    var downvote: Color
    var save: Color
    var selectedInteractionBarItem: Color
}

@Observable
class Palette: PaletteProviding {
    /// Current color palette
    private var palette: ColorPalette
    
    static var main: Palette = .init()
    
    init() {
        @AppStorage("colorPalette") var colorPalette: PaletteOption = .standard
        self.palette = colorPalette.palette
    }
    
    /// Updates the current color palette
    func changePalette(to newPalette: PaletteOption) {
        palette = newPalette.palette
    }
    
    // ColorProviding conformance
    var primary: Color { palette.primary }
    var background: Color { palette.background }
    var secondaryBackground: Color { palette.secondaryBackground }
    var tertiaryBackground: Color { palette.tertiaryBackground }
    var accent: Color { palette.accent }
    
    var upvote: Color { palette.upvote }
    var downvote: Color { palette.downvote }
    var save: Color { palette.save }
    var selectedInteractionBarItem: Color { palette.selectedInteractionBarItem }
}
