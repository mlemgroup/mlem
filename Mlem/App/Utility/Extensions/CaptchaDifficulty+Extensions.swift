//
//  CaptchaDifficulty+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 29/07/2024.
//

import Foundation
import MlemMiddleware

extension CaptchaDifficulty {
    var label: LocalizedStringResource {
        switch self {
        case .easy: "Easy"
        case .medium: "Medium"
        case .hard: "Hard"
        }
    }
}
