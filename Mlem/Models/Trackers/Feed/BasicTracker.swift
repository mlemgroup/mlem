//
//  BasicTracker.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-10-15.
//
import Foundation
import Semaphore

class BasicTracker<Item: TrackerItem> {
    @Published var items: [Item] = .init()

    // loading state
    private var ids: Set<ContentModelIdentifier> = .init(minimumCapacity: 1000)
    private(set) var page: Int = 0 // number of the most recently loaded page--0 indicates no content
    private var loadThreshold: ContentModelIdentifier?
    private(set) var loadingState: LoadingState = .idle
    private let loadingSemaphore: AsyncSemaphore = .init(value: 1)

    // loading behavior governors
    var internetSpeed: InternetSpeed
    var unreadOnly: Bool?
    var sortType: TrackerSortType

    init(internetSpeed: InternetSpeed, unreadOnly: Bool, sortType: TrackerSortType) {
        self.internetSpeed = internetSpeed
        self.unreadOnly = unreadOnly
        self.sortType = sortType
    }

    // MARK: - External methods
    
    func refresh(clearBeforeRefresh: Bool) async throws {
        try await loadPage(1, clearBeforeRefresh: clearBeforeRefresh)
    }

    func reset() async {
        do {
            try await loadPage(0)
        } catch {
            assertionFailure("Exception thrown when resetting, this should not be possible!")
            clear() // this is not a thread-safe use of clear, but I'm using it here because we should never get here
        }
    }

    // MARK: - Internal tracking methods
    
    /// Loads the requested page. To account for the fact that multiple threads might request a load at the same time, this function requires that the caller pass in what it thinks is the next page to load. If that is not the next page by the time that call is allowed to execute, its request will be ignored.
    /// This grants this function an additional, extremely useful property: calling `await loadPage` while `loadPage` is already being executed will, practically speaking, await the in-flight request.
    /// There is additional logic to handle the reset case--because page is updated at the end of this call, if reset() set the page to 0 itself and a reset call were made while another loading call was in-flight, the in-flight call would update page before the reset call went through and the reset call's load would be aborted. Instead, this method takes on responsibility for resetting--calling it on page 0 clears the tracker, and page 1 refreshes it
    /// - Parameter page: page number to load
    func loadPage(_ pageToLoad: Int, clearBeforeRefresh: Bool = false) async throws {
        assert(!clearBeforeRefresh || pageToLoad == 1, "clearBeforeRefresh cannot be true if not loading page 1")

        print("[\(Item.self) tracker] attempting to load page \(pageToLoad)")

        // only one thread may execute this function at a time
        await loadingSemaphore.wait()
        defer { loadingSemaphore.signal() }

        // special reset cases
        if pageToLoad == 0 {
            print("[\(Item.self) tracker] received request to load page 0")
            clear()
            return
        }

        if pageToLoad == 1 {
            print("[\(Item.self) tracker] received request to load page 1")
            if clearBeforeRefresh {
                clear()
            } else {
                // if not clearing before reset, still clear these two fields in order to sanitize the loading state--we just keep the items in place until we have received new ones, which will be set below
                page = 0
                ids = .init(minimumCapacity: 1000)
            }
        }

        // do nothing if this is not the next page to load
        guard pageToLoad == page + 1 else {
            print("[\(Item.self) tracker] will not load page \(pageToLoad) of items (have loaded \(page) pages)")
            return
        }

        let newItems = try await fetchPage(page: pageToLoad)
        page = pageToLoad

        // if no messages show up and no error was thrown, there's nothing left to load
        if newItems.isEmpty {
            print("[\(Item.self) tracker] received no items, loading must be finished")
            loadingState = .done
            return
        }

        // TODO: repeat load until we have enough things
        
        let allowedItems = storeIdsAndDedupe(newItems: newItems)

        // if loading page 1, we can just do a straight assignment regardless of whether we did clearBeforeReset
        if page == 1 {
            await setItems(newItems: allowedItems)
        } else {
            await add(toAdd: allowedItems)
        }

        loadingState = .idle
    }

    // MARK: - Helpers
    
    /// Fetches the next page of items. This method must be overridden by the instantiating class because different items are loaded differently. Relies on the instantiating class to handle fetch parameters such as unreadOnly and page size.
    /// - Parameters:
    ///   - page: page number to fetch
    /// - Returns: requested page of items
    func fetchPage(page: Int) async throws -> [Item] {
        assertionFailure("This method must be implemented by the child tracker")
        return []
    }

    @MainActor
    func update(with item: Item) {
        guard let index = items.firstIndex(where: { $0.uid == item.uid }) else {
            return
        }

        items[index] = item
    }
    
    // TODO: figure out filtering
    // idea 1: put it in storeIdsAndDedupe
    
    /// Given an array of Items, adds their ids to ids. Returns the input filtered to only items not previously present in ids.
    /// - Parameter newMessages: array of MessageModel
    /// - Returns: newMessages, filtered to only messages not already present in ids
    private func storeIdsAndDedupe(newItems: [Item]) -> [Item] {
        let accepted = newItems.filter { ids.insert($0.uid).inserted }
        return accepted
    }

    private func setItems(newItems: [Item]) async {
        print("[\(Item.self) tracker] setting items with \(newItems.count)")
        await MainActor.run {
            items = newItems
        }
    }
    
    /// Adds the given items to the items array
    /// - Parameter toAdd: items to add
    private func add(toAdd: [Item]) async {
        await MainActor.run {
            items.append(contentsOf: toAdd)
        }
    }

    /// Clears the tracker to an empty state.
    /// **WARNING:**
    /// **DO NOT** call this method from anywhere but loadPage! This is *purely* a helper function for loadPage and *will* lead to unexpected behavior if called elsewhere!
    private func clear() {
        print("[\(Item.self) tracker] clearing tracker (removing \(items.count) items)")
        ids = .init(minimumCapacity: 1000)
        items = .init()
        page = 0
        loadingState = .idle
    }
}
