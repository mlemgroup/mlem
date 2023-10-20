//
//  ParentTracker.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-10-15.
//
import Dependencies
import Foundation

class ParentTracker<Item: TrackerItem>: ObservableObject, ParentTrackerProtocol {
    @Dependency(\.errorHandler) var errorHandler

    @Published var items: [Item] = .init()

    private var childTrackers: [any ChildTrackerProtocol] = .init()
    private var internetSpeed: InternetSpeed
    private var sortType: TrackerSortType
    private var loadingState: LoadingState = .idle

    init(internetSpeed: InternetSpeed, sortType: TrackerSortType, childTrackers: [any ChildTrackerProtocol]) {
        self.internetSpeed = internetSpeed
        self.sortType = sortType
        self.childTrackers = childTrackers

        for var child in self.childTrackers {
            child.setParentTracker(self)
        }
    }

    func addChildTracker(_ newChild: some ChildTrackerProtocol) {
        var newChild = newChild
        newChild.setParentTracker(self)
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
        if clearBeforeFetch {
            await reset()
        }

        await loadNextPage()
    }

    /// Loads the next page of items
    func loadNextPage() async {
        await addItems(fetchNextItems(numItems: internetSpeed.pageSize))
    }

    /// Resets the tracker to an empty state
    func reset() async {
        RunLoop.main.perform {
            self.items = .init()
        }

        // note: this could in theory be run in parallel, but these calls should be super quick so it shouldn't matter
        for child in childTrackers {
            await child.reset(notifyParent: false)
        }
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
