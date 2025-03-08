//
//  File.swift
//  Theming
//
//  Created by Sjmarf on 2025-03-06.
//

import SwiftUI

public extension Palette {
    static let `default`: Self = .init(
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
        thumbnailBackground: Color(UIColor.systemGray4),
        contrastingLabel: .white,
        accent: .blue,
        neutralAccent: .gray,
        colorfulAccents: [.orange, .pink, .blue, .green, .purple, .indigo, .mint, .teal, .yellow],
        commentIndentColors: [.red, .orange, .yellow, .green, .blue, .purple],
        positive: .green,
        negative: .red,
        warning: .red,
        caution: .orange,
        upvote: .blue,
        downvote: .red,
        save: .green,
        read: .purple,
        favorite: .blue,
        administration: .teal,
        moderation: .cyan,
        federatedFeed: .blue,
        localFeed: .purple,
        subscribedFeed: .red,
        moderatedFeed: .cyan,
        savedFeed: .green,
        inbox: .purple
    )
}
