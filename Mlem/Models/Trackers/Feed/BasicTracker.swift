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
    var sortType: TrackerSortType

    init(internetSpeed: InternetSpeed, sortType: TrackerSortType) {
        self.internetSpeed = internetSpeed
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
            await clear() // this is not a thread-safe use of clear, but I'm using it here because we should never get here
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
            print("[\(Item.self) tracker] clearing")
            await clear()
            return
        }

        if pageToLoad == 1 {
            print("[\(Item.self) tracker] refreshing")
            if clearBeforeRefresh {
                await clear()
            } else {
                // if not clearing before reset, still clear these fields in order to sanitize the loading state--we just keep the items in place until we have received new ones, which will be set below
                page = 0
                ids = .init(minimumCapacity: 1000)
                loadingState = .idle
            }
        }
        
        // do not continue to load if done. this check has to come after the clear/refresh cases because those cases can be called on a .done tracker
        guard loadingState != .done else {
            print("[\(Item.self) tracker] done loading, will not continue")
            return
        }

        // do nothing if this is not the next page to load
        guard pageToLoad == page + 1 else {
            print("[\(Item.self) tracker] will not load page \(pageToLoad) of items (have loaded \(page) pages)")
            return
        }
        
        var newItems: [Item] = .init()
        while newItems.count < internetSpeed.pageSize {
            let fetchedItems = try await fetchPage(page: page + 1)
            print("found \(fetchedItems.count) items")
            page += 1
            
            if fetchedItems.isEmpty {
                print("[\(Item.self) tracker] received no items, loading must be finished")
                loadingState = .done
                break
            }
            
            newItems.append(contentsOf: fetchedItems)
        }
        
        let allowedItems = storeIdsAndDedupe(newItems: newItems)

        // if loading page 1, we can just do a straight assignment regardless of whether we did clearBeforeReset
        if page == 1 {
            await setItems(newItems: allowedItems)
        } else {
            await add(toAdd: allowedItems)
        }

        if loadingState != .done {
            loadingState = .idle
        }
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
    
    /// Filters out items according to the given filtering function.
    /// - Parameter filter: function that, given an Item, returns true if the item should REMAIN in the tracker
    @discardableResult func filter(with filter: @escaping (Item) -> Bool) async -> Int {
        let newItems = items.filter(filter)
        let removed = items.count - newItems.count
        
        await MainActor.run {
            items = newItems
        }
        
        return removed
    }
    
    /// Given an array of Items, adds their ids to ids. Returns the input filtered to only items not previously present in ids.
    /// - Parameter newMessages: array of MessageModel
    /// - Returns: newMessages, filtered to only messages not already present in ids
    private func storeIdsAndDedupe(newItems: [Item]) -> [Item] {
        let accepted = newItems.filter { ids.insert($0.uid).inserted }
        return accepted
    }

    @MainActor
    func setItems(newItems: [Item]) {
        print("[\(Item.self) tracker] setting items with \(newItems.count)")
        items = newItems
    }
    
    /// Adds the given items to the items array
    /// - Parameter toAdd: items to add
    @MainActor
    private func add(toAdd: [Item]) async {
        items.append(contentsOf: toAdd)
    }

    /// Clears the tracker to an empty state.
    /// **WARNING:**
    /// **DO NOT** call this method from anywhere but loadPage! This is *purely* a helper function for loadPage and *will* lead to unexpected behavior if called elsewhere!
    private func clear() async {
        print("[\(Item.self) tracker] clearing tracker (removing \(items.count) items)")
        ids = .init(minimumCapacity: 1000)
        page = 0
        loadingState = .idle
        await setItems(newItems: .init())
    }
}