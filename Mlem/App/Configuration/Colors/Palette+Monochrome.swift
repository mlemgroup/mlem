//
//  Palette+Monochrome.swift
//  Mlem
//
//  Created by Sjmarf on 2025-03-08.
//

import Foundation
import SwiftUI
import Theming

extension Palette {
    static let monochrome: Self = .init(
        bordered: false,
        label: .init(
            primary: .primary,
            secondary: .secondary,
            tertiary: .init(uiColor: .tertiaryLabel)
        ),
        background: .init(
            primary: .init(uiColor: .systemBackground),
            secondary: .init(uiColor: .secondarySystemBackground),
            tertiary: .init(uiColor: .tertiarySystemBackground)
        ),
        groupedBackground: .init(
            primary: .init(uiColor: .systemGroupedBackground),
            secondary: .init(uiColor: .secondarySystemGroupedBackground),
            tertiary: .init(uiColor: .tertiarySystemGroupedBackground)
        ),
        thumbnailBackground: Color(uiColor: .systemGray4),
        contrastingLabel: Color(uiColor: .systemBackground),
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
        ],
        accountAgeColors: [.gray],
        positive: .primary,
        negative: .primary,
        warning: .primary,
        caution: .primary,
        upvote: .primary,
        downvote: .primary,
        save: .primary,
        read: .primary,
        favorite: .primary,
        administration: .primary,
        moderation: .primary,
        federatedFeed: Color(uiColor: .darkGray),
        localFeed: Color(uiColor: .darkGray),
        subscribedFeed: Color(uiColor: .darkGray),
        moderatedFeed: Color(uiColor: .darkGray),
        savedFeed: Color(uiColor: .darkGray),
        popularFeed: Color(uiColor: .darkGray),
        suggestedFeed: Color(uiColor: .darkGray),
        inbox: Color(uiColor: .darkGray),
        fediseerEndorsement: .gray
    )
}
