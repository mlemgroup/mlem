//
//  MessagesTrackerNew.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-09-23.
//
import Dependencies
import Foundation

class MessagesTrackerNew: ObservableObject, InboxFeedSubTracker {
    @Dependency(\.messageRepository) var messageRepository
    @Dependency(\.errorHandler) var errorHandler

    @Published var messages: [MessageModel] = .init()

    private var ids: Set<ContentModelIdentifier> = .init(minimumCapacity: 1000)
    private var page: Int = 1
    private var loadThreshold: ContentModelIdentifier?
    private(set) var isLoading: Bool = false

    // params governing behavior
    private var internetSpeed: InternetSpeed
    private var unreadOnly: Bool

    /// Parent tracker. If present, will be updated when this tracker is updated
    var parentTracker: InboxTrackerNew?

    /// Index of the first non-consumed item in messages
    private var cursor: Int = 0

    // MARK: - multi-feed support methods
    
    // TODO: dynamic loading
    
    private let sortType: InboxSortType = .published

    init(internetSpeed: InternetSpeed, unreadOnly: Bool) {
        self.internetSpeed = internetSpeed
        self.unreadOnly = unreadOnly
    }

    func nextItemSortVal(sortType: InboxSortType) -> StreamItem<InboxSortVal> {
        assert(sortType == self.sortType, "Conflicting types for sortType! This will lead to unexpected sorting behavior.")

        if cursor < messages.count {
            return .present(messages[cursor].getInboxSortVal(sortType: sortType))
        } else if isLoading {
            return .loading
        } else {
            print("no more messages")
            return .absent
        }
    }

    func consumeNextItem() -> StreamItem<InboxItemNew> {
        if cursor < messages.count {
            cursor += 1
            return .present(InboxItemNew.message(messages[cursor - 1]))
        } else if isLoading {
            return .loading
        } else {
            print("no more messages")
            return .absent
        }
    }

    // MARK: - basic loading operations
    
    func refresh(clearBeforeFetch: Bool = false) async throws {
        if clearBeforeFetch { try await reset() }
        
        try await reset(andLoad: true)
    }

    // filter
    
    // update
    
    /// Retrieves the next page of items, incrementing page counter and adding the new items to the tracker
    func loadNextPage() async throws {
        let newMessages = try await fetchNextPage()
        let toAdd = storeIdsAndDedupe(newMessages: newMessages)
        add(toAdd: toAdd)
    }

    // reply
    
    // MARK: - helpers
    
    /// Fetches the given page of items and increments the page counter
    /// - Returns: next page of items
    private func fetchNextPage() async throws -> [MessageModel] {
        print("fetching new messages")
        let newMessages = try await messageRepository.loadMessages(
            page: page,
            limit: internetSpeed.pageSize,
            unreadOnly: unreadOnly
        )
        print("got \(newMessages.count) messages")
        page += 1
        return newMessages
    }

    private func add(toAdd: [MessageModel]) {
        // TODO: filtering
        messages.append(contentsOf: toAdd)
    }

    /// Resets the tracker state to empty. If passed an array of messages, resets it to contain only those messages.
    /// - Parameter andLoad if true, will load a new page of messages and populate the tracker with them
    private func reset(andLoad: Bool = false) async throws {
        page = 1
        ids = .init(minimumCapacity: 1000)
        messages = andLoad ? try await storeIdsAndDedupe(newMessages: fetchNextPage()) : .init()
    }

    /// Given an array of MessageModel, adds their message ids to ids. Returns the input filtered to only items not previously present in ids.
    /// - Parameter newMessages: array of MessageModel
    /// - Returns: newMessages, filtered to only messages not already present in ids
    private func storeIdsAndDedupe(newMessages: [MessageModel]) -> [MessageModel] {
        let accepted = newMessages.filter { ids.insert($0.uid).inserted }
        return accepted
    }
}
