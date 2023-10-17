//
//  ChildTrackerProtocol.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-10-15.
//

import Foundation

protocol ChildTrackerProtocol {
    associatedtype Item: ChildTrackerItem
    
    mutating func setParentTracker(_ newParent: ParentTracker<Item.ParentType>)
    
    mutating func consumeNextItem() -> Item.ParentType?
    
    func nextItemSortVal(sortType: TrackerSortType) async throws -> TrackerSortVal?
}
