//
//  StandardTracker.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-10-15.
//

import Dependencies
import Foundation
import Semaphore

/// Enumeration of loading actions
enum LoadAction {
    /// Clears the tracker
    case clear
    
    /// Resets the tracker. If true, clears before resetting.
    case refresh(Bool)
    
    /// Load the requested page
    case loadPage(Int)
    
    /// Load the requested cursor
    case loadCursor(String)
}

class StandardTracker<Item: TrackerItem>: CoreTracker<Item> {
    @Dependency(\.errorHandler) var errorHandler
    
    /// loading state
    private var ids: Set<ContentModelIdentifier> = .init(minimumCapacity: 1000)
    /// number of the most recently loaded page. 0 indicates no content.
    private(set) var page: Int = 0
    /// cursor of the most recently loaded page. nil indicates no content.
    private(set) var loadingCursor: String?
    private let loadingSemaphore: AsyncSemaphore = .init(value: 1)
    
    // MARK: - Main actor methods
    
    @MainActor
    func update(with item: Item) {
        guard let index = items.firstIndex(where: { $0.uid == item.uid }) else {
            return
        }

        items[index] = item
    }

    // MARK: - External methods
    
    override func loadMoreItems() async {
        do {
            let pageToLoad = page + 1
            
            if pageToLoad == 1 {
                try await load(action: .refresh(false))
            } else {
                try await load(action: .loadPage(pageToLoad))
            }
            
            // try await load(page + 1)
        } catch {
            errorHandler.handle(error)
        }
    }
    
    func refresh(clearBeforeRefresh: Bool) async throws {
        try await load(action: .refresh(clearBeforeRefresh))
    }

    func reset() async {
        do {
            // try await load(0)
            try await load(action: .clear)
        } catch {
            assertionFailure("Exception thrown when resetting, this should not be possible!")
            await clearHelper() // this is not a thread-safe use of clear, but I'm using it here because we should never get here
        }
    }

    // MARK: - Internal tracking methods
    
    /// Performs the requested loading operation. To account for the fact that multiple threads might request a load at the same time, this function requires that the caller pass in what it thinks is the next page or cursor to load. If that is not the next page/cursor by the time that call is allowed to execute, its request will be ignored.
    /// This grants this function an additional, extremely useful property: calling `await loadPage` while `loadPage` is already being executed will, practically speaking, await the in-flight request.
    /// There is additional logic to handle the reset case--because page is updated at the end of this call, if reset() set the page to 0 itself and a reset call were made while another loading call was in-flight, the in-flight call would update page before the reset call went through and the reset call's load would be aborted. Instead, this method takes on responsibility for resetting--calling it on page 0 clears the tracker, and page 1 refreshes it
    /// - Parameter page: page number to load
    func load(action: LoadAction) async throws {
        // only one thread may execute this function at a time
        await loadingSemaphore.wait()
        defer { loadingSemaphore.signal() }
        
        switch action {
        case .clear:
            print("[\(Item.self) tracker] clearing")
            await clearHelper()
        case let .refresh(clearBeforeRefresh):
            print("[\(Item.self) tracker] refreshing")
            try await refreshHelper(clearBeforeRefresh: clearBeforeRefresh)
        case let .loadPage(pageToLoad):
            print("[\(Item.self) tracker] loading page \(pageToLoad)")
            try await loadPageHelper(pageToLoad)
        case .loadCursor:
            print("[\(Item.self) tracker] loading cursor")
            assertionFailure("Not implemented!")
        }
    }

    // MARK: - Helpers
    
    /// Fetches the next page of items. This method must be overridden by the instantiating class because different items are loaded differently. Relies on the instantiating class to handle fetch parameters such as unreadOnly and page size.
    /// - Parameters:
    ///   - page: page number to fetch
    /// - Returns: requested page of items
    func fetchPage(page: Int) async throws -> [Item] {
        preconditionFailure("This method must be implemented by the inheriting class")
    }
    
    /// Filters out items according to the given filtering function.
    /// - Parameter filter: function that, given an Item, returns true if the item should REMAIN in the tracker
    @discardableResult func filter(with filter: @escaping (Item) -> Bool) async -> Int {
        let newItems = items.filter(filter)
        let removed = items.count - newItems.count
        
        await setItems(newItems)
        
        return removed
    }
    
    /// Given an array of Items, adds their ids to ids. Returns the input filtered to only items not previously present in ids.
    /// - Parameter newMessages: array of MessageModel
    /// - Returns: `newMessages`, filtered to only messages not already present in ids
    private func storeIdsAndDedupe(newItems: [Item]) -> [Item] {
        let accepted = newItems.filter { ids.insert($0.uid).inserted }
        return accepted
    }

    /// Clears the tracker to an empty state.
    /// - Warning: **DO NOT** call this method from anywhere but `load`! This is *purely* a helper function for `load` and *will* lead to unexpected behavior if called elsewhere!
    private func clearHelper() async {
        ids = .init(minimumCapacity: 1000)
        page = 0
        await setLoading(.idle)
        await setItems(.init())
    }
    
    /// Clears
    /// - Warning: **DO NOT** call this method from anywhere but `load`! This is *purely* a helper function for `load` and *will* lead to unexpected behavior if called elsewhere!
    private func refreshHelper(clearBeforeRefresh: Bool) async throws {
        if clearBeforeRefresh {
            await clearHelper()
        } else {
            // if not clearing before reset, still clear these fields in order to sanitize the loading state--we just keep the items in place until we have received new ones, which will be set by loadPage/loadCursor
            page = 0
            loadingCursor = nil
            ids = .init(minimumCapacity: 1000)
            await setLoading(.idle)
        }
        try await loadPageHelper(1)
    }
    
    /// Loads a given page of items
    /// - Parameter pageToLoad: page to load
    /// - Warning: **DO NOT** call this method from anywhere but `load`! This is *purely* a helper function for `load` and *will* lead to unexpected behavior if called elsewhere!
    private func loadPageHelper(_ pageToLoad: Int) async throws {
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
            page += 1
            
            if fetchedItems.isEmpty {
                print("[\(Item.self) tracker] fetch returned no items, setting loading state to done")
                await setLoading(.done)
                break
            }
            
            newItems.append(contentsOf: fetchedItems)
        }
        
        let allowedItems = storeIdsAndDedupe(newItems: newItems)

        // if loading page 1, we can just do a straight assignment regardless of whether we did clearBeforeReset
        if pageToLoad == 1 {
            await setItems(allowedItems)
        } else {
            await addItems(allowedItems)
        }

        if loadingState != .done {
            await setLoading(.idle)
        }
    }
}
