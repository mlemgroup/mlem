//
//  InboxTrackerNew.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-09-23.
//

import Foundation

class InboxTrackerNew: ObservableObject {
    @Published var items: [InboxItemNew] = .init()
    
    // internal state trackers
    private var ids: Set<ContentModelIdentifier> = .init(minimumCapacity: 1000)
    private(set) var isLoading: Bool = false // accessible but not published because it causes lots of bad view redraws

    // sub-trackers
    private var messagesTracker: MessagesTrackerNew
    private var mentionsTracker: MentionsTrackerNew
    private var repliesTracker: RepliesTrackerNew
    
    private let sortType: InboxSortType = .published
    
    // other
    private(set) var internetSpeed: InternetSpeed
    
    init(
        internetSpeed: InternetSpeed,
        messagesTracker: MessagesTrackerNew,
        mentionsTracker: MentionsTrackerNew,
        repliesTracker: RepliesTrackerNew
    ) {
        self.internetSpeed = internetSpeed
        self.messagesTracker = messagesTracker
        self.mentionsTracker = mentionsTracker
        self.repliesTracker = repliesTracker
    }
    
    // MARK: loading methods

    /// Loads the next page of items
    func loadNextPage() {
        defer { isLoading = false }
        isLoading = true
        
        // TODO: handle no more items to load
        
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
    }
    
    // MARK: helpers
    
    /// Computes and returns the next item to consume from the InboxFeedSubTrackers.
    /// - Returns: InboxItemNew of the top-sorted item from the three trackers if present, nil otherwise
    private func computeNextItem() -> InboxItemNew? {
        // TODO: other sorts--need to ensure that the trackers are all sorted the same way

        var sortVal: InboxSortVal?
        var trackerToConsume: (any InboxFeedSubTracker)?
        
        if let nextMessageSortVal = messagesTracker.nextItemSortVal(sortType: sortType) {
            sortVal = nextMessageSortVal
            trackerToConsume = messagesTracker
        }
        if let nextMentionSortVal = mentionsTracker.nextItemSortVal(sortType: sortType),
           nextMentionSortVal.shouldSortBefore(other: sortVal) {
            sortVal = nextMentionSortVal
            trackerToConsume = mentionsTracker
        }
        if let nextReplySortVal = repliesTracker.nextItemSortVal(sortType: sortType), nextReplySortVal.shouldSortBefore(other: sortVal) {
            // don't need to update sortVal because this is the last one
            trackerToConsume = repliesTracker
        }
        
        if let trackerToConsume {
            return trackerToConsume.consumeNextItem()
        }
        return nil
    }
}
