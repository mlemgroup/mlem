//
//  InboxTrackerNew.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-09-23.
//
import Foundation

enum LoadingState {
    case loading, waiting, idle, done
}

class InboxTrackerNew: ObservableObject {
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
    private var repliesTracker: RepliesTrackerNew
    private var mentionsTracker: MentionsTrackerNew
    private var messagesTracker: MessagesTrackerNew
    
    private let sortType: InboxSortType = .published
    
    private var allTrackersReady: Bool { !(
        repliesTracker.loadingState == .loading ||
            mentionsTracker.loadingState == .loading ||
            messagesTracker.loadingState == .loading
    ) }
    
    // other
    private(set) var internetSpeed: InternetSpeed
    
    init(
        internetSpeed: InternetSpeed,
        repliesTracker: RepliesTrackerNew,
        mentionsTracker: MentionsTrackerNew,
        messagesTracker: MessagesTrackerNew
    ) {
        self.internetSpeed = internetSpeed
        
        self.repliesTracker = repliesTracker
        self.mentionsTracker = mentionsTracker
        self.messagesTracker = messagesTracker
        
        // give child trackers reference to self to propagate state updates
        self.repliesTracker.parentTracker = self
        self.mentionsTracker.parentTracker = self
        self.messagesTracker.parentTracker = self
    }
    
    // MARK: child tracker handling
    
    func childFinishedLoading() {
        print("child finished loading | loadingState: \(loadingState)\t| allTrackersReady: \(allTrackersReady)")
        if loadingState == .waiting, allTrackersReady {
            print("ready to load, loading next page")
            loadNextPage()
        } else {
            print("no items will be loaded")
        }
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
    func refresh(clearBeforeFetch: Bool = false) {
        if clearBeforeFetch {
            reset()
        }
        
        loadNextPage()
    }
    
    /// Fetches the requested number of items. If any of the child trackers are loading and not enough items have been loaded to trigger autoloading behavior, sets the loading status to waiting. All requests for more items should go through this method, as it handles loading state.
    /// - Returns: requested number of items, if possible
    private func fetchNextItems(numItems: Int) -> [InboxItemNew] {
        guard loadingState == .idle || (loadingState == .waiting && allTrackersReady) else {
            print("cannot fetch more items right now.\n    loading state: \(loadingState)\n    trackers ready: \(allTrackersReady)")
            return .init()
        }
        
        assert(numItems > abs(AppConstants.infiniteLoadThresholdOffset), "cannot load fewer items than infinite load offset")
        
        loadingState = .loading
        
        var newItems: [InboxItemNew] = .init()
        for idx in 0 ..< numItems {
            let nextItem = computeNextItem()
            switch nextItem {
            case let .present(item):
                // if item is present, add it to newItems
                // dev note: don't need to dedupe because that's handled at the child trackers
                newItems.append(item)
                assert(!ids.contains(item.uid))
                ids.insert(item.uid)
            case .loading:
                // if item is loading, two cases.
                // if we don't have enough items for infinite load, set loading to `waiting` to trigger a reload when the trackers finish loading
                // if we do have enough items for infinite load, call it a day and go to `idle`
                if idx < abs(AppConstants.infiniteLoadThresholdOffset) {
                    loadingState = .waiting
                } else {
                    loadingState = .idle
                }
                return newItems
            case .absent:
                // if there is no next item, we're done
                loadingState = .done
                return newItems
            }
        }
        
        return newItems
    }
    
    /// Loads the next page of items
    func loadNextPage() {
        addItems(fetchNextItems(numItems: internetSpeed.pageSize))
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
    private func computeNextItem() -> StreamItem<InboxItemNew> {
        // TODO: other sorts--need to ensure that the trackers are all sorted the same way
        var sortVal: InboxSortVal?
        var trackerToConsume: (any InboxFeedSubTracker)?
  
        for tracker: InboxFeedSubTracker in [messagesTracker] { // [messagesTracker, mentionsTracker, repliesTracker] {
            // (sortVal, trackerToConsume) = compareNextTrackerItem(
            let nextItem = compareNextTrackerItem(
                sortType: sortType,
                sortVal: sortVal,
                trackerToConsume: trackerToConsume,
                trackerToCompare: tracker
            )
            
            switch nextItem {
            case let .present(item):
                (sortVal, trackerToConsume) = item
            case .loading:
                return .loading
            case .absent:
                return .absent
            }
        }
        
        if let trackerToConsume {
            return trackerToConsume.consumeNextItem()
        }
        return .absent
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
    ) -> StreamItem<(InboxSortVal?, (any InboxFeedSubTracker)?)> {
        let sortValToCompare = trackerToCompare.nextItemSortVal(sortType: sortType)
        switch sortValToCompare {
        case let .present(val):
            if val.shouldSortBefore(other: sortVal) {
                return .present((val, trackerToCompare))
            }
            return .present((sortVal, trackerToConsume))
        case .loading:
            return .loading
        case .absent:
            return .present((sortVal, trackerToConsume))
        }
    }
}
