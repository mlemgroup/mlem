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
    }

    func consumeNextItem() -> InboxItemNew? {
        assert(cursor < messages.count, "consumeNextItem called on a tracker without a next item!")
        
        if cursor < messages.count {
            cursor += 1
            return InboxItemNew.message(messages[cursor - 1])
        }
        
        return nil
    }

    // MARK: - basic loading operations
    
    func loadNextPage() async throws {
        try await loadPage(page + 1)
    }
    
    func refresh(clearBeforeReset: Bool = false) async throws {
        try await loadPage(1, clearBeforeReset: clearBeforeReset)
    }

    // filter
    
    // update
    
    /// Loads the requested page. To account for the fact that multiple threads might request a load at the same time, this function requires that the caller pass in what it thinks is the next page to load. If that is not the next page by the time that call is allowed to execute, its request will be ignored.
    /// There is additional logic to handle the reset case--because page is updated at the end of this call, if reset() set the page to 0 itself and a reset call were made while another loading call was in-flight, the in-flight call would update page before the reset call went through and the reset call's load would be aborted.
    /// - Parameter page: page number to load
    private func loadPage(_ pageToLoad: Int, clearBeforeReset: Bool = false) async throws {
        assert(!clearBeforeReset || pageToLoad == 1, "clearBeforeReset cannot be true if not loading page 1")
        
        print("attempting to load page \(pageToLoad) of messages")
        
        // only one thread may execute this function at a time
        await loadingSemaphore.wait()
        defer { loadingSemaphore.signal() }
        
        // special reset cases
        if pageToLoad == 0 {
            print("received request to load page 0")
            clear()
            return
        }
        
        if pageToLoad == 1 {
            print("received request to reload page 1")
            if clearBeforeReset {
                clear()
            } else {
                // if not clearing before reset, still get rid of these--we just handle the messages themselves differently
                page = 0
                ids = .init(minimumCapacity: 1000)
            }
        }
        
        // do nothing if this is not the next page to load
        guard pageToLoad == page + 1 else {
            print("will not load page \(pageToLoad) of messages (have loaded \(page) pages)")
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
        
        let allowedMessages = storeIdsAndDedupe(newMessages: newMessages)
        
        // if loading page 1, we can just do a straight assignment regardless of whether we did clearBeforeReset
        if page == 1 {
            messages = allowedMessages
        } else {
            add(toAdd: allowedMessages)
        }
    
        loadingState = .idle
    }

    private func add(toAdd: [MessageModel]) {
        // TODO: filtering
        messages.append(contentsOf: toAdd)
    }
    
    /// Clears the tracker to an empty state.
    /// WARNING: do NOT call this method from anywhere but loadPage!
    private func clear() {
        print("clearing messages tracker")
        ids = .init(minimumCapacity: 1000)
        messages = .init()
        page = 0
    }

    /// Given an array of MessageModel, adds their message ids to ids. Returns the input filtered to only items not previously present in ids.
    /// - Parameter newMessages: array of MessageModel
    /// - Returns: newMessages, filtered to only messages not already present in ids
    private func storeIdsAndDedupe(newMessages: [MessageModel]) -> [MessageModel] {
        let accepted = newMessages.filter { ids.insert($0.uid).inserted }
        return accepted
    }
}
