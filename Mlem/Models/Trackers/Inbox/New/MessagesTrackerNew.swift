//
//  MessagesTrackerNew.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-09-23.
//
import Dependencies
import Foundation
import Semaphore

class MessagesTrackerNew: ObservableObject, InboxFeedSubTracker {
    @Dependency(\.messageRepository) var messageRepository
    @Dependency(\.errorHandler) var errorHandler

    @Published var messages: [MessageModel] = .init()

    private var ids: Set<ContentModelIdentifier> = .init(minimumCapacity: 1000)
    private var page: Int = 0 // number of the most recently loaded page--0 indicates no content
    private var loadThreshold: ContentModelIdentifier?
    private(set) var loadingState: TrackerLoadingState = .idle
    private let loadingSemaphore: AsyncSemaphore = .init(value: 1)

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

    func nextItemSortVal(sortType: InboxSortType) async throws -> InboxSortVal? {
        assert(sortType == self.sortType, "Conflicting types for sortType! This will lead to unexpected sorting behavior.")

        if cursor < messages.count {
            return messages[cursor].getInboxSortVal(sortType: sortType)
        } else {
            // if done loading, return nil
            if loadingState == .done {
                print("done loading!")
                return nil
            }
            
            // otherwise, wait for the next page to load and try to return the first value
            // if the next page is already loading, this call to loadNextPage will be noop, but still wait until that load completes thanks to the semaphore
            try await loadPage(page + 1)
            return cursor < messages.count ? messages[cursor].getInboxSortVal(sortType: sortType) : nil
        }
        
//        if cursor < messages.count {
//            return messages[cursor].getInboxSortVal(sortType: sortType)
//        } else if loadingState == .loading {
//            // if no message after the cursor and currently loading, notify that loading
//            print("no message after cursor, but loading")
//            return .loading
//        } else if loadingState == .idle {
//            print("no message after cursor, initializing loading")
//            // if no messages after cursor and idle, start loading and notify
//            Task(priority: .userInitiated) {
//                try await loadNextPage()
//            }
//            return .loading
//        } else {
//            print("no more messages")
//            return .absent
//        }
    }

    func consumeNextItem() -> StreamItem<InboxItemNew> {
        if cursor < messages.count {
            cursor += 1
            return .present(InboxItemNew.message(messages[cursor - 1]))
        } else if loadingState == .loading {
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
    
    /// Loads the requested page. If the requested page has already been loaded, does nothing.
    /// - Parameter page: page number to load
    func loadPage(_ pageToLoad: Int) async throws {
        // only one thread may execute this function at a time
        await loadingSemaphore.wait()
        defer { loadingSemaphore.signal() }
        
        // if we've already loaded this page, do nothing
        guard pageToLoad > page else {
            print("will not load page \(pageToLoad), have already loaded \(page)")
            return
        }
        
        let newMessages = try await messageRepository.loadMessages(
            page: pageToLoad,
            limit: internetSpeed.pageSize,
            unreadOnly: unreadOnly
        )
        page = pageToLoad
        
        // if no messages show up and no error was thrown, there's nothing left to load
        if newMessages.isEmpty {
            print("received no messages!")
            loadingState = .done
            return
        }
        
        // TODO: repeat load until we have enough things
        
        add(toAdd: storeIdsAndDedupe(newMessages: newMessages))
        loadingState = .idle
    }
    
    /// Retrieves the next page of items, incrementing page counter and adding the new items to the tracker
//    func loadNextPage() async throws {
//        guard loadingState == .idle else {
//            print(loadingState == .done ? "no messages left to load" : "already loading")
//            return
//        }
//
//        // TODO: lock this all so that only one load happens at once
//
//        loadingState = .loading
//
//        let newMessages = try await fetchNextPage()
//        let toAdd = storeIdsAndDedupe(newMessages: newMessages)
//        add(toAdd: toAdd)
//
//        // TODO: EOF
//        loadingState = .idle
//    }

    // reply
    
    // MARK: - helpers
    
    /// Fetches the given page of items and increments the page counter
    /// - Returns: next page of items
//    private func fetchNextPage() async throws -> [MessageModel] {
//        print("fetching new messages")
//        let newMessages = try await messageRepository.loadMessages(
//            page: page,
//            limit: internetSpeed.pageSize,
//            unreadOnly: unreadOnly
//        )
//        print("got \(newMessages.count) messages")
//        page += 1
//        return newMessages
//    }

    private func add(toAdd: [MessageModel]) {
        // TODO: filtering
        messages.append(contentsOf: toAdd)
    }

    /// Resets the tracker state to empty. If passed an array of messages, resets it to contain only those messages.
    /// - Parameter andLoad if true, will load a new page of messages and populate the tracker with them
    private func reset(andLoad: Bool = false) async throws {
        ids = .init(minimumCapacity: 1000)
        if andLoad {
            loadPage(1)
        }
        // messages = andLoad ? try await storeIdsAndDedupe(newMessages: fetchNextPage()) : .init()
    }

    /// Given an array of MessageModel, adds their message ids to ids. Returns the input filtered to only items not previously present in ids.
    /// - Parameter newMessages: array of MessageModel
    /// - Returns: newMessages, filtered to only messages not already present in ids
    private func storeIdsAndDedupe(newMessages: [MessageModel]) -> [MessageModel] {
        let accepted = newMessages.filter { ids.insert($0.uid).inserted }
        return accepted
    }
}
