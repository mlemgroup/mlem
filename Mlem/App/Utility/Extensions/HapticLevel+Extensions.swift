//
//  HapticLevel+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 2025-05-29.
//

import Foundation
import Haptics

extension HapticLevel {
    var label: LocalizedStringResource {
        switch self {
        case .low: "Low"
        case .high: "High"
        }
    }
}
