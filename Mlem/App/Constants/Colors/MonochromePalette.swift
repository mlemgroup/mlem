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
        thumbnailBackground: Color(UIColor.systemGray4),
        accent: .primary,
        upvote: .primary,
        downvote: .primary,
        save: .primary,
        selectedInteractionBarItem: Color(UIColor.systemBackground),
        administration: .primary,
        moderation: .primary,
        orange: .primary
    )
}
