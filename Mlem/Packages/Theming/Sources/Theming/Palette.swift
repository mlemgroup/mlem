//
//  Palette.swift
//  Theming
//
//  Created by Sjmarf on 2025-03-06.
//

import SwiftUI

public struct Palette {
    public var label: ColorHierarchy
    public var background: ColorHierarchy
    public var groupedBackground: ColorHierarchy
    
    public var contrastingLabel: Color
    public var thumbnailBackground: Color
    
    public var accent: Color
    public var neutralAccent: Color
    public var colorfulAccents: [Color]
    public var commentIndentColors: [Color]
    
    public var positive: Color
    public var negative: Color
    public var warning: Color
    public var caution: Color
    
    public var upvote: Color
    public var downvote: Color
    public var save: Color
    public var administration: Color
    public var moderation: Color
    
    public var federatedFeed: Color
    public var localFeed: Color
    public var subscribedFeed: Color
    public var moderatedFeed: Color
    public var savedFeed: Color
}

public extension Palette {
    struct ColorHierarchy {
        public var primary: Color
        public var secondary: Color
        public var tertiary: Color
    }
}
