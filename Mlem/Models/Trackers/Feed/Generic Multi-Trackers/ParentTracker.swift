//
//  ParentTracker.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-10-15.
//

import Dependencies
import Foundation

class ParentTracker<Item: TrackerItem>: ObservableObject {
    @Dependency(\.errorHandler) var errorHandler
    
    @Published var items: [Item] = .init()
    
    private var childTrackers: [any ChildTrackerProtocol]
    private var internetSpeed: InternetSpeed
    private var sortType: TrackerSortType
    private var loadingState: TrackerLoadingState = .idle
    
    init(internetSpeed: InternetSpeed, sortType: TrackerSortType, childTrackers: [any ChildTrackerProtocol]) {
        self.internetSpeed = internetSpeed
        self.sortType = sortType
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
    func refresh(clearBeforeFetch: Bool = false) async {
        // TODO: handle child trackers
        
        if clearBeforeFetch {
            reset()
        }
        
        await loadNextPage()
    }
    
    /// Loads the next page of items
    func loadNextPage() async {
        await addItems(fetchNextItems(numItems: internetSpeed.pageSize))
    }
    
    /// Resets the tracker to an empty state
    /// - Parameter newItems: optional; if provided, will pre-populate the tracker with these items
    func reset(with newItems: [Item] = .init()) {
        items = newItems
    }
    
    // MARK: private loading methods
    
    private func fetchNextItems(numItems: Int) async -> [Item] {
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
        
        if var trackerToConsume {
            return trackerToConsume.consumeNextItem() as? Item
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
            if let rhsVal = try await rhsTracker.nextItemSortVal(sortType: sortType),
               rhsVal.shouldSortBefore(lhsVal) {
                return (rhsVal, rhsTracker)
            }

            return (lhsVal, lhsTracker)
        } catch {
            errorHandler.handle(error)
            return (lhsVal, lhsTracker)
        }
    }
}
