//
//  InboxTrackerNew.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-09-23.
//
import Foundation

enum LoadingState {
    case loading, waiting, idle
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
    
    // MARK: loading methods
    
    /// Refreshes the tracker, clearing all items and loading new ones
    /// - Parameter clearBeforeFetch: true to clear items before fetch
    func refresh(clearBeforeFetch: Bool = false) {
        if clearBeforeFetch {
            reset()
        }
    }
    
    /// Fetches the requested number of items. If any of the child trackers are loading and not enough items have been loaded to trigger autoloading behavior, sets the loading status to waiting. All requests for more items should go through this method, as it handles loading state.
    /// - Returns: requested number of items, if possible
    func fetchNextItems(numItems: Int) -> [InboxItemNew] {
        guard loadingState == .idle
        
        loadingState = .loading
    }
    
    /// Loads the next page of items
    func loadNextPage() {
        defer { isLoading = false }
        isLoading = true
        
        // TODO: handle no more items to load
        // TODO: handle sub-tracker loading (return, but flag status as awaiting)
        
        // perform what amounts to a 3-way merge sort between the child trackers until we have the requisite number of items--the trick here is that the consumeNextItem() method of the sub-trackers makes each one _appear_ to be an infinite stream of sorted, filtered, deduped items, allowing us to do a high-level merge sort here--all of the dynamic loading is handled by the trackers themselves via consumeNextItem()
        // note that this method assumes that sorting, filtering, and deduping is all handled by the trackers
        var newItems: [InboxItemNew] = .init()
        for _ in 0 ..< internetSpeed.pageSize {
            if let nextItem = computeNextItem() {
                newItems.append(nextItem)
                assert(!ids.contains(nextItem.uid))
                ids.insert(nextItem.uid)
            } else {
                break
            }
        }
        
        items.append(contentsOf: newItems)
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
        
        // TODO: handle .published being different from *all* the others--maybe make a generic absent/loading enum?
  
        for tracker: InboxFeedSubTracker in [messagesTracker, mentionsTracker, repliesTracker] {
            (sortVal, trackerToConsume) = compareNextTrackerItem(
                sortType: sortType,
                sortVal: sortVal,
                trackerToConsume: trackerToConsume,
                trackerToCompare: tracker
            )
        }
        
        if let trackerToConsume {
            return trackerToConsume.consumeNextItem()
        }
        return .absent
    }
    
    func compareNextTrackerItem(
        sortType: InboxSortType,
        sortVal: InboxSortVal?,
        trackerToConsume: (any InboxFeedSubTracker)?,
        trackerToCompare: any InboxFeedSubTracker
    ) -> (InboxSortVal?, (any InboxFeedSubTracker)?) {
        let sortValToCompare = trackerToCompare.nextItemSortVal(sortType: sortType)
        switch sortValToCompare {
        case let .present(val):
            if val.shouldSortBefore(other: sortVal) {
                return (val, trackerToCompare)
            }
            return (sortVal, trackerToConsume)
        case .loading:
            assertionFailure("todo: handle loading")
        case .absent:
            return (sortVal, trackerToConsume)
        }
    }
}
