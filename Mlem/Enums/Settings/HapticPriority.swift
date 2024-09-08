//
//  HapticPriority.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-08-10.
//

import Foundation

/// Enum to denote priority of haptic feedback. The levels denote:
/// - sentinel: denotes that the user has selected no haptics. Should never be used as a haptic priority!
/// - high: denotes a haptic that always plays if the user has selected any degree of haptic feedback
/// - low: denotes a haptic that only plays if the user has selected "all" haptic feedback
enum HapticPriority: String, CaseIterable, Comparable, Codable {
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
    var label: String {
        switch self {
        case .sentinel: return "None"
        case .high: return "Some"
        case .low: return "All"
        }
    }
    
    var id: Self { self }
}
