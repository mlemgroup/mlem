//
//  CommentBarTheme.swift
//  Mlem
//
//  Created by Sjmarf on 2026-11-05.
//

import Theming
import SwiftUI

enum CommentBarTheme: Codable, Identifiable, Hashable {
    case rainbow
    case accent
    case colorfulAccent(Int)
    case primaryLabel
    case neutralAccent
    case tertiaryLabelMonochrome

    var id: Self { self }

    static func allCases(in palette: Palette) -> [Self] {
        var cases: [Self] = [.rainbow, .accent]
        cases += (0..<palette.colorfulAccents.count).map { .colorfulAccent($0) }
        cases += [.primaryLabel, .neutralAccent, .tertiaryLabelMonochrome]
        return cases
    }

    var label: LocalizedStringResource {
        switch self {
        case .rainbow: "Rainbow"
        case .accent: "Accent"
        case .primaryLabel: "Primary"
        case .neutralAccent: "Neutral"
        case .tertiaryLabelMonochrome: "Monochrome"
        case let .colorfulAccent(value): "Accent #\(value)"
        }
    }

    func colors(in palette: Palette) -> [Color] {
        switch self {
        case .rainbow:
            palette.commentIndentColors
        case .accent:
            palette.accent.gradientArray()
        case let .colorfulAccent(index):
            palette.colorfulAccents[index % palette.colorfulAccents.count].gradientArray()
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
        let stepCount = 6

        let start: CGFloat = 0.1
        let end: CGFloat = 1

        let interval = (end - start) / CGFloat(stepCount - 1)
        let opacities = (0..<stepCount).map { start + CGFloat($0) * interval }

        return opacities.map {
            self.opacity($0)
        }
    }
}
