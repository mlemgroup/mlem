//
//  MultiTracker.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-10-14.
//

import Dependencies
import Foundation

/// Generic type for a multi-tracker.
/// In order to use this, you must define a symmetric pair of types: one conforming to ParentTrackerItem and one conforming to ChildTrackerItem, with each referring to the other as their ChildType and ParentType, respectively. Your ChildTrackerItem should itself be a
class MultiTracker<Item: ParentTrackerItem>: ObservableObject {
    @Dependency(\.errorHandler) var errorHandler
    
    @Published var items: [Item] = .init()
    
    // internal state trackers
    private var ids: Set<ContentModelIdentifier> = .init(minimumCapacity: 1000)
    private var loadingState: LoadingState = .idle
    
    // loading behavior governors
    private let sortType: Item.SortType
    private(set) var internetSpeed: InternetSpeed
    
    // sub-trackers
    private var childTrackers: [ChildTracker<Item.ChildType>]
    
    init(
        sortType: Item.SortType,
        internetSpeed: InternetSpeed,
        childTrackers: [ChildTracker<Item.ChildType>]
    ) {
        self.sortType = sortType
        self.internetSpeed = internetSpeed
        self.childTrackers = childTrackers
    }
    
    // MARK: items manipulation methods

    // note: all of the methods in here run on the main loop. items shouldn't be touched directly, but instead should be manipulated using these methods to ensure we aren't publishing updates from the background
    
    func addItems(_ newItems: [Item]) {
        RunLoop.main.perform {
            self.items.append(contentsOf: newItems)
        }
    }
    
    // MARK: loading methods
    
    /// Refreshes the tracker, clearing all items and loading new ones
    /// - Parameter clearBeforeFetch: true to clear items before fetch
    func refresh(clearBeforeFetch: Bool = false) async where Item.ChildType.ParentItem == Item {
        // TODO: handle child trackers
        
        if clearBeforeFetch {
            reset()
        }
        
        await loadNextPage()
    }
    
    /// Fetches the requested number of items. If any of the child trackers are loading and not enough items have been loaded to trigger autoloading behavior, sets the loading status to waiting. All requests for more items should go through this method, as it handles loading state.
    /// - Returns: requested number of items, if possible
    private func fetchNextItems(numItems: Int) async -> [Item] where Item.ChildType.ParentItem == Item {
        assert(numItems > abs(AppConstants.infiniteLoadThresholdOffset), "cannot load fewer items than infinite load offset")
        
        loadingState = .loading
        
        var newItems: [Item] = .init()
        for _ in 0 ..< numItems {
            if let nextItem = await computeNextItem() {
                newItems.append(nextItem)
            } else {
                print("no next item found!")
                loadingState = .done
                break
            }
        }
        
        return newItems
    }
    
    /// Loads the next page of items
    func loadNextPage() async where Item.ChildType.ParentItem == Item {
        await addItems(fetchNextItems(numItems: internetSpeed.pageSize))
    }
    
    /// Resets the tracker to an empty state
    /// - Parameter newItems: optional; if provided, will pre-populate the tracker with these items
    func reset(with newItems: [Item] = .init()) {
        ids = .init(minimumCapacity: 1000)
        items = newItems
    }
    
    // MARK: helpers
    
    /// Computes, consumes, and returns the next sorted item from the InboxFeedSubTrackers.
    /// - Returns: InboxItemNew of the top-sorted item from the three trackers if present, nil otherwise
    private func computeNextItem() async -> Item? where
        Item.SortType == Item.ChildType.ParentItem.SortType,
        Item.SortVal == Item.ChildType.ParentItem.SortVal,
        Item.ChildType.ParentItem == Item {
        // TODO: other sorts--need to ensure that the trackers are all sorted the same way
        var sortVal: Item.SortVal?
        var trackerToConsume: ChildTracker<Item.ChildType>?
  
        for tracker in childTrackers {
            (sortVal, trackerToConsume) = await compareNextTrackerItem(
                sortType: sortType,
                sortVal: sortVal,
                trackerToConsume: trackerToConsume,
                trackerToCompare: tracker
            )
        }
        
        if let trackerToConsume {
            return trackerToConsume.consumeNextItem()
        }
        
        return nil
    }
    
    /// Compares the current sorting value of `trackerToConsume` with the current sorting value of `trackerToCompare`. Returns a tuple of the lower sorting value and its associated tracker.
    /// - Parameters:
    ///   - sortType: type of sorting being performed
    ///   - sortVal: sorting value of the next item in trackerToConsume
    ///   - trackerToConsume: tracker currently set for consumption
    ///   - trackerToCompare: tracker to compare with
    /// - Returns: tuple of the earlier-sorted inbox sort value and its associated tracker
    private func compareNextTrackerItem(
        sortType: Item.SortType,
        sortVal: Item.SortVal?,
        trackerToConsume: ChildTracker<Item.ChildType>?,
        trackerToCompare: ChildTracker<Item.ChildType>
    ) async -> (Item.SortVal?, ChildTracker<Item.ChildType>?) where
        Item.ChildType.ParentItem.SortType == Item.SortType,
        Item.ChildType.ParentItem.SortVal == Item.SortVal {
        do {
            if let sortValToCompare = try await trackerToCompare.nextItemSortVal(sortType: sortType),
               sortValToCompare.shouldSortBefore(sortVal) {
                return (sortValToCompare, trackerToCompare)
            }
            return (sortVal, trackerToConsume)
        } catch {
            errorHandler.handle(error)
            return (sortVal, trackerToConsume)
        }
    }
}
