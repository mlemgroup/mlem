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
        background: Color(UIColor.systemBackground),
        secondaryBackground: Color(UIColor.secondarySystemBackground),
        tertiaryBackground: Color(UIColor.tertiarySystemBackground),
        accent: .primary,
        upvote: .primary,
        downvote: .primary,
        save: .primary,
        selectedInteractionBarItem: Color(UIColor.systemBackground)
    )
}
