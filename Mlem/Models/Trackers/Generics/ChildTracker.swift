//
//  ChildTracker.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-10-16.
//

import Foundation

class TrackerStream {
    weak var parentTracker: (any ParentTrackerProtocol)?
    var cursor: Int
    
    init(parentTracker: (any ParentTrackerProtocol)? = nil) {
        self.parentTracker = parentTracker
        self.cursor = 0
    }
}

class ChildTracker<Item: TrackerItem, ParentItem: TrackerItem>: StandardTracker<Item>, ChildTrackerProtocol {
    private var streams: [UUID: TrackerStream] = .init()
    
    private(set) var sortType: TrackerSortType
    
    var allItems: [ParentItem] { items.map { toParent(item: $0) }}
    
    init(internetSpeed: InternetSpeed, sortType: TrackerSortType) {
        self.sortType = sortType
        super.init(internetSpeed: internetSpeed)
    }

    func toParent(item: Item) -> ParentItem {
        preconditionFailure("This method must be implemented by the inheriting class")
    }
    
    func addParentTracker(_ newParent: any ParentTrackerProtocol) -> UUID {
        let newCursorId = UUID()
        print("DEBUG [\(Item.self) tracker] added parent tracker, gave UUID \(newCursorId)")
        streams[newCursorId] = .init(parentTracker: newParent)
        return newCursorId
    }
    
    /// Gets the next item in the feed stream and increments the cursor
    /// - Returns: next item in the feed stream
    /// - Warning: This is NOT a thread-safe function! Only one thread at a time per stream may call this function!
    func consumeNextItem(streamId: UUID) -> ParentItem? {
        guard var stream = streams[streamId], stream.parentTracker != nil else {
            print("[\(Item.self) tracker] (consumeNextItem) could not find stream or parent for \(streamId)")
            return nil
        }
        
        assert(
            stream.cursor < items.count,
            "consumeNextItem called on a tracker without a next item (cursor: \(stream.cursor), count: \(items.count))!"
        )

        if stream.cursor < items.count {
            stream.cursor += 1
            return toParent(item: items[stream.cursor - 1])
        }

        return nil
    }

    /// Gets the sort value of the next item in feed stream for a given sort type without affecting the cursor. The sort type must match the sort type of this tracker.
    /// - Parameter sortType: type of sorting being performed
    /// - Returns: sorting value of the next tracker item corresponding to the given sort type
    /// - Warning: This is NOT a thread-safe function! Only one thread at a time per stream may call this function!
    func nextItemSortVal(streamId: UUID, sortType: TrackerSortType) async throws -> TrackerSortVal? {
        assert(sortType == self.sortType, "Conflicting types for sortType! This will lead to unexpected sorting behavior.")
        
        guard var stream = streams[streamId], stream.parentTracker != nil else {
            print("[\(Item.self) tracker] (nextItemSortVal) could not find stream or parent for \(streamId)")
            return nil
        }

        if stream.cursor < items.count {
            return items[stream.cursor].sortVal(sortType: sortType)
        } else {
            // if done loading, return nil
            if loadingState == .done {
                return nil
            }

            // otherwise, wait for the next page to load and try to return the first value
            // if the next page is already loading, this call to loadNextPage will be noop, but still wait until that load completes thanks to the semaphore
            await loadMoreItems()
            return stream.cursor < items.count ? items[stream.cursor].sortVal(sortType: sortType) : nil
        }
    }
    
    /// Resets the cursor to 0 but does not unload any items
    func resetCursor(streamId: UUID) {
        guard var stream = streams[streamId], stream.parentTracker != nil else {
            print("[\(Item.self) tracker] (resetCursor) could not find stream or parent for \(streamId)")
            return
        }
        
        stream.cursor = 0
    }

    func refresh(streamId: UUID, clearBeforeRefresh: Bool, notifyParent: Bool = true) async throws {
        guard var stream = streams[streamId], let parentTracker = stream.parentTracker else {
            print("[\(Item.self) tracker] (refresh) could not find stream or parent for \(streamId)")
            return
        }
        
        try await refresh(clearBeforeRefresh: clearBeforeRefresh)
        stream.cursor = 0

        await parentTracker.refresh(clearBeforeFetch: clearBeforeRefresh)
    }

    func reset(streamId: UUID, notifyParent: Bool = true) async {
        guard var stream = streams[streamId], let parentTracker = stream.parentTracker else {
            print("[\(Item.self) tracker] (reset) could not find stream or parent for \(streamId)")
            return
        }
        
        await clear()
        stream.cursor = 0
        if notifyParent {
            await parentTracker.reset()
        }
    }
    
    @discardableResult override func filter(with filter: @escaping (Item) -> Bool) async -> Int {
        let newItems = items.filter(filter)
        let removed = items.count - newItems.count
        
        for var stream in streams.values {
            stream.cursor = 0
        }
        await setItems(newItems)
        
        return removed
    }
}
