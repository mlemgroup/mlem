//
//  MonochromePalette.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-05-06.
//

import Foundation
import SwiftUI

extension ColorPalette {
    static let monochrome: ColorPalette = .init(
        primary: .primary,
        secondary: .secondary,
        tertiary: Color(uiColor: .tertiaryLabel),
        background: Color(uiColor: .systemBackground),
        secondaryBackground: Color(uiColor: .secondarySystemBackground),
        tertiaryBackground: Color(uiColor: .tertiarySystemBackground),
        groupedBackground: Color(uiColor: .systemGroupedBackground),
        secondaryGroupedBackground: Color(uiColor: .secondarySystemGroupedBackground),
        tertiaryGroupedBackground: Color(UIColor.tertiarySystemGroupedBackground),
        thumbnailBackground: Color(uiColor: .systemGray4),
        positive: .primary,
        negative: .primary,
        warning: .primary,
        caution: .primary,
        upvote: .primary,
        downvote: .primary,
        save: .primary,
        read: .primary,
        favorite: .primary,
        selectedInteractionBarItem: Color(uiColor: .systemBackground),
        administration: .primary,
        moderation: .primary,
        federatedFeed: Color(uiColor: .darkGray),
        localFeed: Color(uiColor: .darkGray),
        subscribedFeed: Color(uiColor: .darkGray),
        moderatedFeed: Color(uiColor: .darkGray),
        savedFeed: Color(uiColor: .darkGray),
        inbox: Color(uiColor: .darkGray),
        accent: .primary,
        neutralAccent: .gray,
        colorfulAccents: [.gray],
        commentIndentColors: [
            Color(uiColor: .systemGray),
            Color(uiColor: .systemGray2),
            Color(uiColor: .systemGray3),
            Color(uiColor: .systemGray4),
            Color(uiColor: .systemGray5),
            Color(uiColor: .systemGray6)
        ]
    )
}
