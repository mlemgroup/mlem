//
//  ChildTracker.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-10-16.
//
import Foundation

class ChildTracker<Item: TrackerItem, ParentItem: TrackerItem>: BasicTracker<Item>, ChildTrackerProtocol, ObservableObject {
    private weak var parentTracker: (any ParentTrackerProtocol)?
    private var cursor: Int = 0

    func toParent(item: Item) -> ParentItem {
        assertionFailure("This method must be implemented by the inheriting class")
        // swiftlint:disable force_cast
        return item as! ParentItem // this cursed and wretched line is only here to make the compiler happy
        // swiftlint:enable force_cast
    }
    
    func setParentTracker(_ newParent: any ParentTrackerProtocol) {
        parentTracker = newParent
    }

    func consumeNextItem() -> ParentItem? {
        assert(cursor < items.count, "consumeNextItem called on a tracker without a next item!")

        if cursor < items.count {
            cursor += 1
            return toParent(item: items[cursor - 1])
        }

        return nil
    }

    func nextItemSortVal(sortType: TrackerSortType) async throws -> TrackerSortVal? {
        assert(sortType == self.sortType, "Conflicting types for sortType! This will lead to unexpected sorting behavior.")

        if cursor < items.count {
            print("[\(Item.self) tracker] next item (\(cursor)) loaded")
            return items[cursor].sortVal(sortType: sortType)
        } else {
            // if done loading, return nil
            if loadingState == .done {
                print("[\(Item.self) tracker] done loading!")
                return nil
            }

            // otherwise, wait for the next page to load and try to return the first value
            // if the next page is already loading, this call to loadNextPage will be noop, but still wait until that load completes thanks to the semaphore
            print("[\(Item.self) tracker] loading next page")
            try await loadPage(page + 1, clearBeforeRefresh: false)
            print("[\(Item.self) tracker] got next page, there are now \(items.count) items")
            return cursor < items.count ? items[cursor].sortVal(sortType: sortType) : nil
        }
    }
    
    /// Resets the cursor to 0 but does not unload any items
    func resetCursor() {
        cursor = 0
    }

    func refresh(clearBeforeRefresh: Bool, notifyParent: Bool = true) async throws {
        try await refresh(clearBeforeRefresh: clearBeforeRefresh)
        cursor = 0

        if notifyParent, let parentTracker {
            print("refreshing parent tracker")
            await parentTracker.refresh(clearBeforeFetch: clearBeforeRefresh)
        }
    }

    func reset(notifyParent: Bool = true) async {
        await reset()
        cursor = 0
        if notifyParent, let parentTracker {
            print("resetting parent tracker")
            await parentTracker.reset()
        }
    }
    
    @discardableResult override func filter(with filter: @escaping (Item) -> Bool) async -> Int {
        let newItems = items.filter(filter)
        let removed = items.count - newItems.count
        
        cursor = 0
        await setItems(newItems: newItems)
        
        return removed
    }
    
    /// Filters items from the parent tracker according to the given filtering criterion
    /// - Parameter filter: function that, given a TrackerItem, returns true if the item should REMAIN in the tracker
    func filterFromParent(with filter: @escaping (any TrackerItem) -> Bool) async {
        if let parentTracker {
            await parentTracker.filter(with: filter)
        } else {
            print("filterFromParent called with no parent tracker!")
        }
    }
}
