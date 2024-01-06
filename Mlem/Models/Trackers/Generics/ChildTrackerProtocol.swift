//
//  ChildTrackerProtocol.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-10-15.
//
import Foundation

protocol ChildTrackerProtocol: AnyObject {
    associatedtype Item: TrackerItem
    associatedtype ParentItem: TrackerItem
    
    /// All items present in the tracker
    /// - Warning: this should not be directly accessed by the parent except to perform filtering!
    var allItems: [ParentItem] { get }

    // MARK: stream support methods
    
    func setParentTracker(_ newParent: any ParentTrackerProtocol)

    func consumeNextItem() -> ParentItem?

    func nextItemSortVal(sortType: TrackerSortType) async throws -> TrackerSortVal?
    
    func resetCursor()

    // MARK: loading methods
    
    func reset(notifyParent: Bool) async

    func refresh(clearBeforeRefresh: Bool, notifyParent: Bool) async throws
    
    @discardableResult func filter(with filter: @escaping (Item) -> Bool) async -> Int
}
