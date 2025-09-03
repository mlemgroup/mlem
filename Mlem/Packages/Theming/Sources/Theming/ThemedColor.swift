//
//  ThemedColor.swift
//  Theming
//
//  Created by Sjmarf on 2025-03-06.
//

import Foundation
import SwiftUI

public struct ThemedColor: ShapeStyle, Hashable, View, Sendable {
    @Environment(\.palette) private var palette
    
    fileprivate let hashString: String
    
    let getColor: @Sendable (Palette) -> Color
    var opacity: CGFloat = 1
    
    public var body: some View {
        resolve(with: palette)
    }

    public func resolve(in environment: EnvironmentValues) -> Color {
        resolve(with: environment.palette)
    }
    
    public func resolve(with palette: Palette) -> Color {
        getColor(palette).opacity(opacity)
    }
    
    public func opacity(_ newOpacity: CGFloat) -> ThemedColor {
        .init(hashString: hashString, getColor: getColor, opacity: newOpacity)
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(hashString)
        hasher.combine(opacity)
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

public extension ShapeStyle where Self == ThemedColor {
    static var themedPrimary: ThemedColor {
        .init(hashString: "primary", getColor: \.label.primary)
    }

    static var themedSecondary: ThemedColor {
        .init(hashString: "secondary", getColor: \.label.secondary)
    }

    static var themedTertiary: ThemedColor {
        .init(hashString: "tertiary", getColor: \.label.tertiary)
    }
    
    static var themedBackground: ThemedColor {
        .init(hashString: "background", getColor: \.background.primary)
    }

    static var themedSecondaryBackground: ThemedColor {
        .init(hashString: "secondaryBackground", getColor: \.background.secondary)
    }

    static var themedTertiaryBackground: ThemedColor {
        .init(hashString: "tertiaryBackground", getColor: \.background.tertiary)
    }
    
    static var themedGroupedBackground: ThemedColor {
        .init(hashString: "groupedBackground", getColor: \.groupedBackground.primary)
    }

    static var themedSecondaryGroupedBackground: ThemedColor {
        .init(hashString: "secondaryGroupedBackground", getColor: \.groupedBackground.secondary)
    }

    static var themedTertiaryGroupedBackground: ThemedColor {
        .init(hashString: "tertiaryGroupedBackground", getColor: \.groupedBackground.tertiary)
    }
    
    static var themedContrastingLabel: ThemedColor {
        .init(hashString: "contrastingLabel", getColor: \.contrastingLabel)
    }

    static var themedThumbnailBackground: ThemedColor {
        .init(hashString: "thumbnailBackground", getColor: \.thumbnailBackground)
    }
    
    static var themedAccent: ThemedColor {
        .init(hashString: "accent", getColor: \.accent)
    }

    static var themedNeutralAccent: ThemedColor {
        .init(hashString: "neutralAccent", getColor: \.neutralAccent)
    }
    
    static func themedColorfulAccent(_ index: Int) -> ThemedColor {
        .init(hashString: "colorfulAccent\(index)") { $0.colorfulAccents[index % $0.colorfulAccents.count] }
    }
    
    static func themedCommentIndentColor(_ index: Int) -> ThemedColor {
        .init(hashString: "commentIndentColor\(index)") { $0.commentIndentColors[index % $0.commentIndentColors.count] }
    }

    static func themedAccountAgeColor(_ index: Int) -> ThemedColor {
        .init(hashString: "accountAgeColor\(index)") { $0.accountAgeColors[min(index, $0.accountAgeColors.count - 1)] }
    }

    static var themedPositive: ThemedColor {
        .init(hashString: "positive", getColor: \.positive)
    }

    static var themedNegative: ThemedColor {
        .init(hashString: "negative", getColor: \.negative)
    }

    static var themedWarning: ThemedColor {
        .init(hashString: "warning", getColor: \.warning)
    }

    static var themedCaution: ThemedColor {
        .init(hashString: "caution", getColor: \.caution)
    }

    static var themedUpvote: ThemedColor {
        .init(hashString: "upvote", getColor: \.upvote)
    }

    static var themedDownvote: ThemedColor {
        .init(hashString: "downvote", getColor: \.downvote)
    }

    static var themedSave: ThemedColor {
        .init(hashString: "save", getColor: \.save)
    }

    static var themedRead: ThemedColor {
        .init(hashString: "read", getColor: \.read)
    }

    static var themedFavorite: ThemedColor {
        .init(hashString: "favorite", getColor: \.favorite)
    }

    static var themedAdministration: ThemedColor {
        .init(hashString: "administration", getColor: \.administration)
    }

    static var themedModeration: ThemedColor {
        .init(hashString: "moderation", getColor: \.moderation)
    }
    
    static var themedFederatedFeed: ThemedColor {
        .init(hashString: "federatedFeed", getColor: \.federatedFeed)
    }

    static var themedLocalFeed: ThemedColor {
        .init(hashString: "localFeed", getColor: \.localFeed)
    }

    static var themedSubscribedFeed: ThemedColor {
        .init(hashString: "subscribedFeed", getColor: \.subscribedFeed)
    }

    static var themedModeratedFeed: ThemedColor {
        .init(hashString: "moderatedFeed", getColor: \.moderatedFeed)
    }

    static var themedSavedFeed: ThemedColor {
        .init(hashString: "savedFeed", getColor: \.savedFeed)
    }

    static var themedPopularFeed: ThemedColor {
        .init(hashString: "popularFeed", getColor: \.popularFeed)
    }

    static var themedSuggestedFeed: ThemedColor {
        .init(hashString: "suggestedFeed", getColor: \.suggestedFeed)
    }

    static var themedInbox: ThemedColor {
        .init(hashString: "inbox", getColor: \.inbox)
    }

    static var themedCommentAccent: ThemedColor { themedColorfulAccent(0) }
    static var themedPostAccent: ThemedColor { themedColorfulAccent(1) }
    static var themedPersonAccent: ThemedColor { themedColorfulAccent(2) }
    static var themedCommunityAccent: ThemedColor { themedColorfulAccent(3) }
    static var themedLockAccent: ThemedColor { themedColorfulAccent(0) }
    
    static var themedDivider: ThemedColor {
        .init(hashString: "divider") {
            Color(light: $0.label.secondary.opacity(0.5), dark: $0.neutralAccent.opacity(0.35))
        }
    }
    
    @_disfavoredOverload
    static var clear: ThemedColor { .init(hashString: "clear", getColor: { _ in .clear }) }
}
