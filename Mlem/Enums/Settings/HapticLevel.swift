//
//  HapticLevel.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-08-10.
//

import Foundation

enum HapticLevel: String, CaseIterable, Comparable {
    
    case none, core, all
    
    var intValue: Int {
        switch self {
        case .none: return 0
        case .core: return 1
        case .all: return 2
        }
    }
    
    static func < (lhs: HapticLevel, rhs: HapticLevel) -> Bool { lhs.intValue < rhs.intValue }
}

extension HapticLevel: SettingsOptions {
    var label: String { self.rawValue.capitalized }
    
    var id: Self { self }
}
