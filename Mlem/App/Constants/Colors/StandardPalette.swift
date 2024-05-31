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
        thumbnailBackground: Color(UIColor.systemGray4),
        accent: .blue,
        positive: .green,
        negative: .red,
        warning: .red,
        upvote: .blue,
        downvote: .red,
        save: .green,
        selectedInteractionBarItem: .white,
        administration: .teal,
        moderation: .cyan,
        orange: .orange
    )
}
