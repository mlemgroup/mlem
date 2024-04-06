//
//  TrackerSort.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-10-15.
//
import Foundation

enum TrackerSort: Comparable {
    case new(Date)
    case old(Date)
    
    // case without associated values for easy type comparison
    enum Case {
        case new, old
    }
    
    var `case`: Case {
        switch self {
        case .new: .new
        case .old: .old
        }
    }
    
    static func < (lhs: TrackerSort, rhs: TrackerSort) -> Bool {
        guard lhs.case == rhs.case else {
            assertionFailure("Compare called on trackersortvals with different types")
            return true
        }
        
        switch lhs {
        case let .new(lhsDate):
            switch rhs {
            case let .new(rhsDate):
                return lhsDate < rhsDate
            default:
                return true
            }
        case let .old(lhsDate):
            switch rhs {
            case let .old(rhsDate):
                return lhsDate > rhsDate
            default:
                return true
            }
        }
    }
}
