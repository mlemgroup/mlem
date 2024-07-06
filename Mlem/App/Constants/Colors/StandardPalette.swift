//
//  DefaultColors.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-05-06.
//

import SwiftUI

extension ColorPalette {
    static let standard: ColorPalette = .init(
        primary: .primary,
        secondary: .secondary,
        tertiary: Color(UIColor.tertiaryLabel),
        background: Color(UIColor.systemBackground),
        secondaryBackground: Color(UIColor.secondarySystemBackground),
        tertiaryBackground: Color(UIColor.tertiarySystemBackground),
        groupedBackground: Color(UIColor.systemGroupedBackground),
        secondaryGroupedBackground: Color(UIColor.secondarySystemGroupedBackground),
        thumbnailBackground: Color(UIColor.systemGray4),
        positive: .green,
        negative: .red,
        warning: .red,
        upvote: .blue,
        downvote: .red,
        save: .green,
        favorite: .blue,
        selectedInteractionBarItem: .white,
        administration: .teal,
        moderation: .cyan,
        federatedFeed: .blue,
        localFeed: .purple,
        subscribedFeed: .red,
        accent: .blue,
        secondaryAccent: .orange,
        commentIndentColors: [Color.red, Color.orange, Color.yellow, Color.green, Color.blue, Color.purple]
    )
}
