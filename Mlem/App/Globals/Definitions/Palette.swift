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
    
    // feeds
    var federatedFeed: Color { get }
    var localFeed: Color { get }
    var subscribedFeed: Color { get }
    var moderatedFeed: Color { get }
    var savedFeed: Color { get }
    
    // accents
    var accent: Color { get }
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
    
    // feeds
    var federatedFeed: Color
    var localFeed: Color
    var subscribedFeed: Color
    var moderatedFeed: Color
    var savedFeed: Color
    
    // accents
    var accent: Color
    var secondaryAccent: Color
    
    var commentIndentColors: [Color]
    
    init(
        primary: Color,
        secondary: Color,
        tertiary: Color,
        background: Color,
        secondaryBackground: Color,
        tertiaryBackground: Color,
        groupedBackground: Color,
        secondaryGroupedBackground: Color,
        thumbnailBackground: Color,
        positive: Color,
        negative: Color,
        warning: Color,
        upvote: Color,
        downvote: Color,
        save: Color,
        favorite: Color,
        selectedInteractionBarItem: Color,
        administration: Color,
        moderation: Color,
        federatedFeed: Color,
        localFeed: Color,
        subscribedFeed: Color,
        moderatedFeed: Color? = nil,
        savedFeed: Color? = nil,
        accent: Color,
        secondaryAccent: Color,
        commentIndentColors: [Color]
    ) {
        self.primary = primary
        self.secondary = secondary
        self.tertiary = tertiary
        self.background = background
        self.secondaryBackground = secondaryBackground
        self.tertiaryBackground = tertiaryBackground
        self.groupedBackground = groupedBackground
        self.secondaryGroupedBackground = secondaryGroupedBackground
        self.thumbnailBackground = thumbnailBackground
        self.positive = positive
        self.negative = negative
        self.warning = warning
        self.upvote = upvote
        self.downvote = downvote
        self.save = save
        self.favorite = favorite
        self.selectedInteractionBarItem = selectedInteractionBarItem
        self.administration = administration
        self.moderation = moderation
        self.federatedFeed = federatedFeed
        self.localFeed = localFeed
        self.subscribedFeed = subscribedFeed
        self.moderatedFeed = moderatedFeed ?? moderation
        self.savedFeed = savedFeed ?? save
        self.accent = accent
        self.secondaryAccent = secondaryAccent
        self.commentIndentColors = commentIndentColors
    }
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
    
    var federatedFeed: Color { palette.federatedFeed }
    var localFeed: Color { palette.localFeed }
    var subscribedFeed: Color { palette.subscribedFeed }
    var moderatedFeed: Color { palette.moderatedFeed }
    var savedFeed: Color { palette.savedFeed }
    
    var accent: Color { palette.accent }
    var secondaryAccent: Color { palette.secondaryAccent }
    
    var commentIndentColors: [Color] { palette.commentIndentColors }
}
