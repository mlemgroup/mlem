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
        accountAgeColors: [
            .green,
            .init(
                // This is `.green.mix(with: .cyan, by: 0.333)`
                light: .init(red: 0.20605278, green: 0.7933883, blue: 0.53997606, alpha: 1.0),
                dark: .init(red: 0.23807898, green: 0.8318233, blue: 0.56663805, alpha: 1.0)
            ),
            .init(
                // This is `.green.mix(with: .cyan, by: 0.666)`
                light: .init(red: 0.2665288, green: 0.7745191, blue: 0.7497066, alpha: 1.0),
                dark: .init(red: 0.2917948, green: 0.8128531, blue: 0.7726594, alpha: 1.0)
            ),
            .cyan,
            .brown
        ],
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
