//
//  CommentBarTheme.swift
//  Mlem
//
//  Created by Sjmarf on 2026-11-05.
//

import Foundation
import Theming

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
}
