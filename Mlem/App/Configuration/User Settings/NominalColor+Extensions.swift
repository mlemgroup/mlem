//
//  NominalColor+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 2026-11-13.
//

import Foundation
import Theming

extension NominalColor {
    var label: LocalizedStringResource {
        switch self {
        case .orange: "Orange"
        case .pink: "Pink"
        case .blue: "Blue"
        case .green: "Green"
        case .purple: "Purple"
        case .indigo: "Indigo"
        case .mint: "Mint"
        case .teal: "Teal"
        case .yellow: "Yellow"
        case .cyan: "Cyan"
        case .red: "Red"
        }
    }
}
