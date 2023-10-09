//
//  InboxSortVal.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-09-23.
//
import Foundation

/// Enumeration of values on which the inbox can be sorted with the relevant type associated. Has two special cases:
/// - loading: indicates that there may be more items, but they are currently being fetched
/// - absent: indicates that there are no more items
enum InboxSortVal: Comparable {
    case published(Date)
    case loading
    case absent
    
    /// Determines whether this should be sorted before another, optional InboxSortVal
    /// - Parameter other: InboxSortVal to compare to
    /// - Returns: true if other is nil or should be sorted after this, false otherwise
    func shouldSortBefore(other: InboxSortVal) -> Bool {
        switch self {
        case let .published(published):
            switch other {
            case let .published(otherPublished):
                return published >= otherPublished
            default:
                // cannot sort on other types
                assertionFailure("shouldSortAfter called with incompatible other type \(self)")
                return true
            }
        default:
            // cannot sort on other types
            assertionFailure("shouldSortAfter called with incompatible type \(self)")
            return true
        }
    }
}

/// Enumeration of the values on which the inbox can be sorted without the relevant type associated
enum InboxSortType {
    case published
}
