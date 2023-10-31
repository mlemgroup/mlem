//
//  ParentTracker.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-10-15.
//

import Dependencies
import Foundation
import Semaphore

class ParentTracker<Item: TrackerItem>: CoreTracker<Item>, ParentTrackerProtocol {
    @Dependency(\.errorHandler) var errorHandler

    private var childTrackers: [any ChildTrackerProtocol] = .init()
    private let loadingSemaphore: AsyncSemaphore = .init(value: 1)

    init(internetSpeed: InternetSpeed, sortType: TrackerSortType, childTrackers: [any ChildTrackerProtocol]) {
        self.childTrackers = childTrackers
        
        super.init(internetSpeed: internetSpeed, sortType: sortType)

        for child in self.childTrackers {
            child.setParentTracker(self)
        }
    }

    func addChildTracker(_ newChild: some ChildTrackerProtocol) {
        newChild.setParentTracker(self)
    }

    // MARK: main actor methods
    
    // note: all of the methods in here run on the main loop. items shouldn't be touched directly, but instead should be manipulated using these methods to ensure we aren't publishing updates from the background

    // MARK: loading methods
    
    /// Loads the next page of items
    override func loadNextPage() async {
        guard loadingState != .done else {
            return
        }
        await addItems(fetchNextItems(numItems: internetSpeed.pageSize))
    }
    
    /// Refreshes the tracker, clearing all items and loading new ones
    /// - Parameter clearBeforeFetch: true to clear items before fetch
    func refresh(clearBeforeFetch: Bool = false) async {
        if clearBeforeFetch {
            await setItems(.init())
        }
        
        await resetChildren()
        
        let newItems = await fetchNextItems(numItems: internetSpeed.pageSize)
        await setItems(newItems)
    }

    /// Resets the tracker to an empty state
    func reset() async {
        await setItems(.init())
        await resetChildren()
    }
    
    private func resetChildren() async {
        // note: this could in theory be run in parallel, but these calls should be super quick so it shouldn't matter
        for child in childTrackers {
            await child.reset(notifyParent: false)
        }
    }
    
    /// Filters out items according to the given filtering function.
    /// - Parameter filter: function that, given an Item, returns true if the item should REMAIN in the tracker
    func filter(with filter: @escaping (Item) -> Bool) async {
        // build set of uids to remove
        var uidsToFilter: Set<ContentModelIdentifier> = .init()
        items.forEach { item in
            if !filter(item) {
                uidsToFilter.insert(item.uid)
            }
        }
        
        // function to remove items from child trackers based on uid--this makes the Item-specific filtering applied here generically applicable to any child tracker
        let filterFunc = { (item: any TrackerItem) in
            !uidsToFilter.contains(item.uid)
        }
        
        // apply filtering to children
        let removed = await withTaskGroup(of: Int.self) { taskGroup in
            childTrackers.forEach { child in
                taskGroup.addTask { await child.filter(with: filterFunc) }
            }
            
            // aggregate count of removed
            var removed = 0
            for await result in taskGroup {
                removed += result
            }
            
            return removed
        }
        
        // reload all non-removed items
        let remaining = items.count - removed
        let newItems = await fetchNextItems(numItems: max(remaining, abs(AppConstants.infiniteLoadThresholdOffset) + 1))
        await setItems(newItems)
    }

    // MARK: private loading methods
    
    private func fetchNextItems(numItems: Int) async -> [Item] {
        assert(numItems > abs(AppConstants.infiniteLoadThresholdOffset), "cannot load fewer items than infinite load offset")
        
        // only one thread may execute this function at a time
        await loadingSemaphore.wait()
        defer { loadingSemaphore.signal() }
        
        await setLoading(.loading)

        var newItems: [Item] = .init()
        for _ in 0 ..< numItems {
            if let nextItem = await computeNextItem() {
                newItems.append(nextItem)
            } else {
                await setLoading(.done)
                break
            }
        }
        
        if loadingState != .done {
            await setLoading(.idle)
        }

        return newItems
    }

    private func computeNextItem() async -> Item? {
        var sortVal: TrackerSortVal?
        var trackerToConsume: (any ChildTrackerProtocol)?

        for tracker in childTrackers {
            (sortVal, trackerToConsume) = await compareNextTrackerItem(
                sortType: sortType,
                lhsVal: sortVal,
                lhsTracker: trackerToConsume,
                rhsTracker: tracker
            )
        }

        if let trackerToConsume {
            guard let nextItem = trackerToConsume.consumeNextItem() as? Item else {
                assertionFailure("Could not convert child item to Item!")
                return nil
            }

            return nextItem
        }

        return nil
    }

    private func compareNextTrackerItem(
        sortType: TrackerSortType,
        lhsVal: TrackerSortVal?,
        lhsTracker: (any ChildTrackerProtocol)?,
        rhsTracker: any ChildTrackerProtocol
    ) async -> (TrackerSortVal?, (any ChildTrackerProtocol)?) {
        do {
            guard let rhsVal = try await rhsTracker.nextItemSortVal(sortType: sortType) else {
                return (lhsVal, lhsTracker)
            }
            
            guard let lhsVal else {
                return (rhsVal, rhsTracker)
            }
            
            return lhsVal > rhsVal ? (lhsVal, lhsTracker) : (rhsVal, rhsTracker)
        } catch {
            errorHandler.handle(error)
            return (lhsVal, lhsTracker)
        }
    }
}
