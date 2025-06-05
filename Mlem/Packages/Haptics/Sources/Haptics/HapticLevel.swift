//
//  HapticPriority.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-06-10.
//

import Foundation

public enum HapticTier: String, CaseIterable, Comparable, Codable {
    case high
    case low
    
    var intValue: Int {
        switch self {
        case .high: return 1
        case .low: return 2
        }
    }
    
    public static func < (lhs: HapticTier, rhs: HapticTier) -> Bool { lhs.intValue < rhs.intValue }
}
