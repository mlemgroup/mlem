//
//  HapticPriority.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-06-10.
//

import Foundation

/// Enum to denote priority of haptic feedback. The levels denote:
/// - sentinel: denotes that the user has selected no haptics. Should never be used as a haptic priority!
/// - high: denotes a haptic that always plays if the user has selected any degree of haptic feedback
/// - low: denotes a haptic that only plays if the user has selected "all" haptic feedback
enum HapticPriority: String, CaseIterable, Comparable {
    case sentinel, high, low
    
    var intValue: Int {
        switch self {
        case .sentinel: return 0
        case .high: return 1
        case .low: return 2
        }
    }
    
    static func < (lhs: HapticPriority, rhs: HapticPriority) -> Bool { lhs.intValue < rhs.intValue }
}

extension HapticPriority: SettingsOptions {
    var label: LocalizedStringResource {
        switch self {
        case .sentinel: "None"
        case .high: "Some"
        case .low: "All"
        }
    }
    
    var id: Self { self }
}
