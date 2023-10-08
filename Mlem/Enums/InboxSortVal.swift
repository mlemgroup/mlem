//
//  InboxSortVal.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-09-23.
//
import Foundation

/// Enumeration of values on which the inbox can be sorted with the relevant type associated
enum InboxSortVal: Comparable {
    case published(Date)
    
    /// Determines whether this should be sorted before another, optional InboxSortVal
    /// - Parameter other: InboxSortVal to compare to
    /// - Returns: true if other is nil or should be sorted after this, false otherwise
    func shouldSortBefore(other: InboxSortVal?) -> Bool {
        guard let other else {
            return true
        }
        
        switch self {
        case let .published(published):
            switch other {
            case let .published(otherPublished):
                return published >= otherPublished
                // this will be useful if we implement other sort types
//            default:
//                assertionFailure("shouldSortAfter called with incompatible types")
//                return true
            }
        }
    }
}

/// Enumeration of the values on which the inbox can be sorted without the relevant type associated
enum InboxSortType {
    case published
}
