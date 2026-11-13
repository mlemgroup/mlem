//
//  CommentBarTheme.swift
//  Mlem
//
//  Created by Sjmarf on 2026-11-05.
//

import Theming
import SwiftUI

enum CommentBarTheme: Codable, Identifiable, Hashable, CaseIterable {
    case rainbow
    case nominal(NominalColor)
    case primaryLabel
    case neutralAccent
    case tertiaryLabelMonochrome

    var id: Self { self }

    static var allCases: [Self] {
        [.rainbow] + NominalColor.allCases.map { .nominal($0) } + [.primaryLabel, .neutralAccent, .tertiaryLabelMonochrome]
    }

    func label(in palette: Palette) -> LocalizedStringResource {
        switch self {
        case .rainbow: "Rainbow"
        case .primaryLabel: "Primary"
        case .neutralAccent: "Neutral"
        case .tertiaryLabelMonochrome: "Monochrome"
        case let .nominal(color): color.label
        }
    }

    func colors(in palette: Palette) -> [Color] {
        switch self {
        case .rainbow:
            palette.commentIndentColors
        case let .nominal(color):
            palette.nominalColors.get(color).gradientArray()
        case .primaryLabel:
            palette.label.primary.gradientArray()
        case .neutralAccent:
            palette.neutralAccent.gradientArray()
        case .tertiaryLabelMonochrome:
            [palette.label.tertiary]
        }
    }
}

private extension Color {
    func gradientArray() -> [Color] {
        let stepCount = 3

        let start: CGFloat = 1
        let end: CGFloat = 0.2

        let interval = (end - start) / CGFloat(stepCount - 1)
        let opacities = (0..<stepCount).map { start + CGFloat($0) * interval }

        return opacities.map {
            self.opacity($0)
        }
    }
}
