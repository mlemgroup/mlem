//
//  ThemedShapeStyle.swift
//  Theming
//
//  Created by Sjmarf on 2025-03-06.
//

import Foundation
import SwiftUI

public struct ThemedShapeStyle: ShapeStyle {
    let getColor: @Sendable (Palette) -> Color
    
    public func resolve(in environment: EnvironmentValues) -> Color {
        resolve(with: environment.palette)
    }
    
    public func resolve(with palette: Palette) -> Color {
        getColor(palette)
    }
}

public extension ShapeStyle where Self == ThemedShapeStyle {
    static var themedPrimary: ThemedShapeStyle { .init(getColor: \.label.primary) }
    static var themedSecondary: ThemedShapeStyle { .init(getColor: \.label.secondary) }
    static var themedTertiary: ThemedShapeStyle { .init(getColor: \.label.tertiary) }
    
    static var themedBackground: ThemedShapeStyle { .init(getColor: \.background.primary) }
    static var themedSecondaryBackground: ThemedShapeStyle { .init(getColor: \.background.secondary) }
    static var themedTertiaryBackground: ThemedShapeStyle { .init(getColor: \.background.tertiary) }
    
    static var themedGroupedBackground: ThemedShapeStyle { .init(getColor: \.groupedBackground.primary) }
    static var themedSecondaryGroupedBackground: ThemedShapeStyle { .init(getColor: \.groupedBackground.secondary) }
    static var themedTertiaryGroupedBackground: ThemedShapeStyle { .init(getColor: \.groupedBackground.tertiary) }
    
    static var themedContrastingLabel: ThemedShapeStyle { .init(getColor: \.contrastingLabel) }
    static var themedThumbnailBackground: ThemedShapeStyle { .init(getColor: \.thumbnailBackground) }
    
    static var themedAccent: ThemedShapeStyle { .init(getColor: \.accent) }
    static var themedNeutralAccent: ThemedShapeStyle { .init(getColor: \.neutralAccent) }
    
    static func themedColorfulAccent(_ index: Int) -> ThemedShapeStyle {
        .init { $0.colorfulAccents[index % $0.colorfulAccents.count] }
    }
    
    static func themedCommentIndentColor(_ index: Int) -> ThemedShapeStyle {
        .init { $0.commentIndentColors[index % $0.commentIndentColors.count] }
    }

    static var themedPositive: ThemedShapeStyle { .init(getColor: \.positive) }
    static var themedNegative: ThemedShapeStyle { .init(getColor: \.negative) }
    static var themedWarning: ThemedShapeStyle { .init(getColor: \.warning) }
    
    static var themedUpvote: ThemedShapeStyle { .init(getColor: \.upvote) }
    static var themedDownvote: ThemedShapeStyle { .init(getColor: \.downvote) }
    static var themedSave: ThemedShapeStyle { .init(getColor: \.save) }
    static var themedAdministration: ThemedShapeStyle { .init(getColor: \.administration) }
    static var themedModeration: ThemedShapeStyle { .init(getColor: \.moderation) }
    
    static var themedFederatedFeed: ThemedShapeStyle { .init(getColor: \.federatedFeed) }
    static var themedLocalFeed: ThemedShapeStyle { .init(getColor: \.localFeed) }
    static var themedSubscribedFeed: ThemedShapeStyle { .init(getColor: \.subscribedFeed) }
    static var themedModeratedFeed: ThemedShapeStyle { .init(getColor: \.moderatedFeed) }
    static var themedSavedFeed: ThemedShapeStyle { .init(getColor: \.savedFeed) }
}
