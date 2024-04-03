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
    
    func addParentTracker(_ newParent: any ParentTrackerProtocol) -> UUID

    func consumeNextItem(streamId: UUID) -> ParentItem?

    func nextItemSortVal(streamId: UUID, sortType: TrackerSortVal.Case) async throws -> TrackerSortVal?
    
    func resetCursor(streamId: UUID)

    // MARK: loading methods
    
    func reset(streamId: UUID, notifyParent: Bool) async

    func refresh(streamId: UUID, clearBeforeRefresh: Bool, notifyParent: Bool) async throws
    
    @discardableResult func filter(with filter: @escaping (Item) -> Bool) async -> Int
    
    func changeSortType(to newSortType: TrackerSortVal.Case)
}
