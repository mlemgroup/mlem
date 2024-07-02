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
        tertiary: Color(UIColor.tertiaryLabel),
        background: Color(UIColor.systemBackground),
        secondaryBackground: Color(UIColor.secondarySystemBackground),
        tertiaryBackground: Color(UIColor.tertiarySystemBackground),
        groupedBackground: Color(UIColor.systemGroupedBackground),
        secondaryGroupedBackground: Color(UIColor.secondarySystemGroupedBackground),
        thumbnailBackground: Color(UIColor.systemGray4),
        accent: .primary,
        positive: .primary,
        negative: .primary,
        warning: .primary,
        upvote: .primary,
        downvote: .primary,
        save: .primary,
        selectedInteractionBarItem: Color(UIColor.systemBackground),
        administration: .primary,
        moderation: .primary,
        secondaryAccent: .primary,
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
