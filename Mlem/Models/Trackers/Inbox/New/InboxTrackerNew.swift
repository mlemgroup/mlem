//
//  InboxTrackerNew.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-09-23.
//

import Dependencies
import Foundation

enum LoadingState {
    case loading, waiting, idle, done
}

class InboxTrackerNew: ObservableObject {
    @Dependency(\.errorHandler) var errorHandler
    
    @Published var items: [InboxItemNew] = .init()
    
    // internal state trackers
    private var ids: Set<ContentModelIdentifier> = .init(minimumCapacity: 1000)
    
    /// Indicates whether the tracker is currently loading more items. This is true in two cases:
    /// - The tracker is currently fetching items from its sub-trackers
    /// - The tracker is currently awaiting a child tracker that is loading. In this state, it will remain loading until the child tracker notifies this tracker that the loading is complete, at which point this tracker will resume loading
    private(set) var isLoading: Bool = false // accessible but not published because it causes lots of bad view redraws
    private var awaitingSubTrackers: Bool = false // indicates whether loading was prematurely suspended
    
    private var loadingState: LoadingState = .idle
    
    // sub-trackers
    private var childTrackers: [InboxFeedSubTracker]
    
//    private var repliesTracker: RepliesTrackerNew
//    private var mentionsTracker: MentionsTrackerNew
//    private var messagesTracker: MessagesTrackerNew
    
    private let sortType: InboxSortType = .published
    
    // other
    private(set) var internetSpeed: InternetSpeed
    
    init(
        internetSpeed: InternetSpeed,
        childTrackers: [InboxFeedSubTracker]
    ) {
        self.internetSpeed = internetSpeed
        self.childTrackers = childTrackers
        
        // TODO: child trackers need references to parent in order to notify about clears and resets
    }

    // MARK: items manipulation methods

    // note: all of the methods in here run on the main loop. items shouldn't be touched directly, but instead should be manipulated using these methods to ensure we aren't publishing updates from the background
    
    func addItems(_ newItems: [InboxItemNew]) {
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
    
    /// Fetches the requested number of items. If any of the child trackers are loading and not enough items have been loaded to trigger autoloading behavior, sets the loading status to waiting. All requests for more items should go through this method, as it handles loading state.
    /// - Returns: requested number of items, if possible
    private func fetchNextItems(numItems: Int) async -> [InboxItemNew] {
        assert(numItems > abs(AppConstants.infiniteLoadThresholdOffset), "cannot load fewer items than infinite load offset")
        
        loadingState = .loading
        
        var newItems: [InboxItemNew] = .init()
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
    func loadNextPage() async {
        await addItems(fetchNextItems(numItems: internetSpeed.pageSize))
    }
    
    /// Resets the tracker to an empty state
    /// - Parameter newItems: optional; if provided, will pre-populate the tracker with these items
    func reset(with newItems: [InboxItemNew] = .init()) {
        ids = .init(minimumCapacity: 1000)
        items = newItems
    }
    
    // MARK: helpers
    
    /// Computes, consumes, and returns the next sorted item from the InboxFeedSubTrackers.
    /// - Returns: InboxItemNew of the top-sorted item from the three trackers if present, nil otherwise
    private func computeNextItem() async -> InboxItemNew? {
        // TODO: other sorts--need to ensure that the trackers are all sorted the same way
        var sortVal: InboxSortVal?
        var trackerToConsume: (any InboxFeedSubTracker)?
  
        for tracker: InboxFeedSubTracker in childTrackers {
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
        sortType: InboxSortType,
        sortVal: InboxSortVal?,
        trackerToConsume: (any InboxFeedSubTracker)?,
        trackerToCompare: any InboxFeedSubTracker
    ) async -> (InboxSortVal?, (any InboxFeedSubTracker)?) {
        do {
            if let sortValToCompare = try await trackerToCompare.nextItemSortVal(sortType: sortType),
               sortValToCompare.shouldSortBefore(other: sortVal) {
                return (sortValToCompare, trackerToCompare)
            }
            return (sortVal, trackerToConsume)
        } catch {
            errorHandler.handle(error)
            return (sortVal, trackerToConsume)
        }
    }
}
