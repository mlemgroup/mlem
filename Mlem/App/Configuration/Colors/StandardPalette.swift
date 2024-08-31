//
//  StandardPalette.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-05-06.
//

import SwiftUI

extension ColorPalette {
    static let standard: ColorPalette = .init(
        supportedModes: .unspecified,
        primary: .primary,
        secondary: .secondary,
        tertiary: Color(UIColor.tertiaryLabel),
        background: Color(UIColor.systemBackground),
        secondaryBackground: Color(UIColor.secondarySystemBackground),
        tertiaryBackground: Color(UIColor.tertiarySystemBackground),
        groupedBackground: Color(UIColor.systemGroupedBackground),
        secondaryGroupedBackground: Color(UIColor.secondarySystemGroupedBackground),
        tertiaryGroupedBackground: Color(UIColor.tertiarySystemGroupedBackground),
        thumbnailBackground: Color(UIColor.systemGray4),
        positive: .green,
        negative: .red,
        warning: .red,
        caution: .orange,
        upvote: .blue,
        downvote: .red,
        save: .green,
        read: .purple,
        favorite: .blue,
        selectedInteractionBarItem: .white,
        administration: .teal,
        moderation: .cyan,
        federatedFeed: .blue,
        localFeed: .purple,
        subscribedFeed: .red,
        inbox: .purple,
        accent: .blue,
        neutralAccent: .gray,
        colorfulAccents: [.orange, .pink, .blue, .green, .purple, .indigo, .mint],
        commentIndentColors: [.red, .orange, .yellow, .green, .blue, .purple]
    )
}
