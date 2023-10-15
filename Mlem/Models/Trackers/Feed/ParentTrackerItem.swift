//
//  TrackerSortable.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-10-14.
//

import Foundation

protocol TrackerSortable {
    func shouldSortBefore(_ other: Self?) -> Bool
}

/// Protocol describing a type that is comprehensible by a parent tracker
/// Trackers can change their sorts, so this needs to be able to handle get the sorting value for any number of different sorting types
protocol ParentTrackerItem {
    /// Overarching type for child trackers
    associatedtype ChildType: ChildTrackerItem
    
    /// Enum of sorting types without an associated value
    associatedtype SortType: Equatable
    
    /// Enum of sorting types with an associated value
    associatedtype SortVal: TrackerSortable
    
    /// Get the sorting value for this item corresponding to the given sort type
    func sortVal(sortType: SortType) -> SortVal
}
