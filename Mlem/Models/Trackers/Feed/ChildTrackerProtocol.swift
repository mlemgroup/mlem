//
//  ChildTrackerProtocol.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-10-15.
//
import Foundation

protocol ChildTrackerProtocol {
    associatedtype Item: ChildTrackerItem

    // stream support methods
    
    mutating func setParentTracker(_ newParent: any ParentTrackerProtocol)

    mutating func consumeNextItem() -> Item.ParentType?

    func nextItemSortVal(sortType: TrackerSortType) async throws -> TrackerSortVal?
    
    func resetCursor()

    // loading methods
    
    func reset(notifyParent: Bool) async

    func refresh(clearBeforeRefresh: Bool, notifyParent: Bool) async throws
    
    @discardableResult func filter(with filter: @escaping (Item) -> Bool) async -> Int
//    @discardableResult func filterFromParent(with filter: @escaping(Item.ParentType) -> Bool)
}
