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
        background: Color(UIColor.systemBackground),
        secondaryBackground: Color(UIColor.secondarySystemBackground),
        tertiaryBackground: Color(UIColor.tertiarySystemBackground),
        accent: .blue,
        success: .green,
        failure: .red,
        upvote: .blue,
        downvote: .red,
        save: .green,
        selectedInteractionBarItem: .white
    )
}
