//
//  OledPalette.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-10-07.
//

import SwiftUI

extension ColorPalette {
    static let oled: ColorPalette = .init(
        supportedModes: .dark,
        bordered: true,
        primary: .primary,
        secondary: .secondary,
        tertiary: Color(UIColor.tertiaryLabel),
        background: .black,
        secondaryBackground: .black,
        tertiaryBackground: .black,
        groupedBackground: .black,
        secondaryGroupedBackground: .black,
        tertiaryGroupedBackground: .black,
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
