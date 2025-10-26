//
//  Palette.swift
//  Theming
//
//  Created by Sjmarf on 2025-03-06.
//

import SwiftUI

@preconcurrency
public struct Palette {
    public var bordered: Bool
    
    public var label: ColorHierarchy
    public var background: ColorHierarchy
    public var groupedBackground: ColorHierarchy
    
    public var thumbnailBackground: Color
    public var contrastingLabel: Color
    
    public var accent: Color
    public var neutralAccent: Color
    public var colorfulAccents: [Color]
    public var commentIndentColors: [Color]
    public var accountAgeColors: [Color]
    
    public var positive: Color
    public var negative: Color
    public var warning: Color
    public var caution: Color
    
    public var upvote: Color
    public var downvote: Color
    public var save: Color
    public var read: Color
    public var favorite: Color
    public var administration: Color
    public var moderation: Color
    
    public var federatedFeed: Color
    public var localFeed: Color
    public var subscribedFeed: Color
    public var moderatedFeed: Color
    public var savedFeed: Color
    public var popularFeed: Color
    public var suggestedFeed: Color
    public var inbox: Color
    
    public init(
        bordered: Bool,
        label: ColorHierarchy,
        background: ColorHierarchy,
        groupedBackground: ColorHierarchy,
        thumbnailBackground: Color,
        contrastingLabel: Color,
        accent: Color,
        neutralAccent: Color,
        colorfulAccents: [Color],
        commentIndentColors: [Color],
        accountAgeColors: [Color],
        positive: Color,
        negative: Color,
        warning: Color,
        caution: Color,
        upvote: Color,
        downvote: Color,
        save: Color,
        read: Color,
        favorite: Color,
        administration: Color,
        moderation: Color,
        federatedFeed: Color,
        localFeed: Color,
        subscribedFeed: Color,
        moderatedFeed: Color,
        savedFeed: Color,
        popularFeed: Color,
        suggestedFeed: Color,
        inbox: Color
    ) {
        self.bordered = bordered
        self.label = label
        self.background = background
        self.groupedBackground = groupedBackground
        self.thumbnailBackground = thumbnailBackground
        self.contrastingLabel = contrastingLabel
        self.accent = accent
        self.neutralAccent = neutralAccent
        self.colorfulAccents = colorfulAccents
        self.commentIndentColors = commentIndentColors
        self.accountAgeColors = accountAgeColors
        self.positive = positive
        self.negative = negative
        self.warning = warning
        self.caution = caution
        self.upvote = upvote
        self.downvote = downvote
        self.save = save
        self.read = read
        self.favorite = favorite
        self.administration = administration
        self.moderation = moderation
        self.federatedFeed = federatedFeed
        self.localFeed = localFeed
        self.subscribedFeed = subscribedFeed
        self.moderatedFeed = moderatedFeed
        self.savedFeed = savedFeed
        self.popularFeed = popularFeed
        self.suggestedFeed = suggestedFeed
        self.inbox = inbox
    }
}

public extension Palette {
    struct ColorHierarchy {
        public var primary: Color
        public var secondary: Color
        public var tertiary: Color
        
        public init(primary: Color, secondary: Color, tertiary: Color) {
            self.primary = primary
            self.secondary = secondary
            self.tertiary = tertiary
        }
    }
}
