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
    var secondary: Color { get }
    var tertiary: Color { get }
    var background: Color { get }
    var secondaryBackground: Color { get }
    var tertiaryBackground: Color { get }
    var groupedBackground: Color { get }
    var secondaryGroupedBackground: Color { get }
    var thumbnailBackground: Color { get }
    var accent: Color { get }
    
    var positive: Color { get }
    var negative: Color { get }
    var warning: Color { get }
    
    // interactions
    var upvote: Color { get }
    var downvote: Color { get }
    var save: Color { get }
    var selectedInteractionBarItem: Color { get }
    
    // entities
    var administration: Color { get }
    var moderation: Color { get }
    
    // accents
    var secondaryAccent: Color { get }
    
    var commentIndentColors: [Color] { get }
}

enum PaletteOption: String, CaseIterable {
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
    var secondary: Color
    var tertiary: Color
    var background: Color
    var secondaryBackground: Color
    var tertiaryBackground: Color
    var groupedBackground: Color
    var secondaryGroupedBackground: Color
    var thumbnailBackground: Color
    var accent: Color

    var positive: Color
    var negative: Color
    var warning: Color
    
    // interactions
    var upvote: Color
    var downvote: Color
    var save: Color
    var favorite: Color
    var selectedInteractionBarItem: Color
    
    // entities
    var administration: Color
    var moderation: Color
    
    // literals
    var secondaryAccent: Color
    
    var commentIndentColors: [Color]
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
    var secondary: Color { palette.secondary }
    var tertiary: Color { palette.tertiary }
    var background: Color { palette.background }
    var secondaryBackground: Color { palette.secondaryBackground }
    var tertiaryBackground: Color { palette.tertiaryBackground }
    var groupedBackground: Color { palette.groupedBackground }
    var secondaryGroupedBackground: Color { palette.secondaryGroupedBackground }
    var thumbnailBackground: Color { palette.thumbnailBackground }
    var accent: Color { palette.accent }
    
    var positive: Color { palette.positive }
    var negative: Color { palette.negative }
    var warning: Color { palette.warning }
    
    var upvote: Color { palette.upvote }
    var downvote: Color { palette.downvote }
    var save: Color { palette.save }
    var favorite: Color { palette.favorite }
    var selectedInteractionBarItem: Color { palette.selectedInteractionBarItem }
    
    var administration: Color { palette.administration }
    var moderation: Color { palette.moderation }
    
    var secondaryAccent: Color { palette.secondaryAccent }
    
    var commentIndentColors: [Color] { palette.commentIndentColors }
}
