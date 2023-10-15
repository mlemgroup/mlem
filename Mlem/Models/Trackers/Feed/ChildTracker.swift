//
//  ChildTracker.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-10-14.
//

import Foundation
import Semaphore

/// Generic class for a sub-tracker; that is, a tracker that can be used to feed a multi tracker. Generic across three parameters:
/// T: type of item that this tracker provides
/// P: type of item that this tracker's parent requires
/// S: enum of sort types that P can be sorted on
class ChildTracker<Item: ChildTrackerItem>: ObservableObject {
    @Published var items: [Item] = .init()
    
    // loading state
    private var ids: Set<ContentModelIdentifier> = .init(minimumCapacity: 1000)
    private var page: Int = 0 // number of the most recently loaded page--0 indicates no content
    private var loadThreshold: ContentModelIdentifier?
    private(set) var loadingState: TrackerLoadingState = .idle
    private let loadingSemaphore: AsyncSemaphore = .init(value: 1)
    
    // loading behavior governors
    private var internetSpeed: InternetSpeed
    private var unreadOnly: Bool?
    private var sortType: Item.ParentItem.SortType
    
    // multi-feed tracking
    private var parentTracker: MultiTracker<Item.ParentItem>?
    private var cursor: Int = 0 // Index of the first non-consumed item in items
    
    init(internetSpeed: InternetSpeed, unreadOnly: Bool, sortType: Item.ParentItem.SortType) {
        self.internetSpeed = internetSpeed
        self.unreadOnly = unreadOnly
        self.sortType = sortType
    }
    
    // MARK: - Multi-feed tracking methods
    
    public func setParentTracker(_ newParent: MultiTracker<Item.ParentItem>) {
        parentTracker = newParent
    }
    
    func consumeNextItem() -> Item.ParentItem? {
        assert(cursor < items.count, "consumeNextItem called on a tracker without a next item!")
        
        if cursor < items.count {
            cursor += 1
            return items[cursor - 1].toParentItem()
        }
        
        return nil
    }
    
    public func nextItemSortVal(sortType: Item.ParentItem.SortType) async throws -> Item.ParentItem.SortVal? {
        assert(sortType == self.sortType, "Conflicting types for sortType! This will lead to unexpected sorting behavior.")

        if cursor < items.count {
            return items[cursor].getSortVal(sortType: sortType)
        } else {
            // if done loading, return nil
            if loadingState == .done {
                print("done loading!")
                return nil
            }
            
            // otherwise, wait for the next page to load and try to return the first value
            // if the next page is already loading, this call to loadNextPage will be noop, but still wait until that load completes thanks to the semaphore
            try await loadPage(page + 1)
            return cursor < items.count ? items[cursor].getSortVal(sortType: sortType) : nil
        }
    }
    
    // MARK: - Internal tracking methods
    
    /// Loads the requested page. To account for the fact that multiple threads might request a load at the same time, this function requires that the caller pass in what it thinks is the next page to load. If that is not the next page by the time that call is allowed to execute, its request will be ignored.
    /// There is additional logic to handle the reset case--because page is updated at the end of this call, if reset() set the page to 0 itself and a reset call were made while another loading call was in-flight, the in-flight call would update page before the reset call went through and the reset call's load would be aborted. Instead, this method takes on responsibility for resetting--calling it on page 0 clears the tracker, and page 1 refreshes it
    /// - Parameter page: page number to load
    private func loadPage(_ pageToLoad: Int, clearBeforeReset: Bool = false) async throws {
        assert(!clearBeforeReset || pageToLoad == 1, "clearBeforeReset cannot be true if not loading page 1")
        
        print("attempting to load page \(pageToLoad)")
        
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
                // if not clearing before reset, still clear these two fields in order to sanitize the loading state--we just keep the items in place until we have received new ones, which will be set below
                page = 0
                ids = .init(minimumCapacity: 1000)
            }
        }
        
        // do nothing if this is not the next page to load
        guard pageToLoad == page + 1 else {
            print("will not load page \(pageToLoad) of items (have loaded \(page) pages)")
            return
        }
        
        let newItems = try await fetchPage(page: pageToLoad)
        page = pageToLoad
        
        // if no messages show up and no error was thrown, there's nothing left to load
        if newItems.isEmpty {
            print("received no items, loading must be finished")
            loadingState = .done
            return
        }
        
        // TODO: repeat load until we have enough things
        
        let allowedItems = storeIdsAndDedupe(newItems: newItems)
        
        // if loading page 1, we can just do a straight assignment regardless of whether we did clearBeforeReset
        if page == 1 {
            items = allowedItems
        } else {
            add(toAdd: allowedItems)
        }
    
        loadingState = .idle
    }
    
    // MARK: - Helpers
    
    /// Fetches the next page of items. This method must be overridden by the instantiating class because different items are loaded differently. Relies on the instantiating class to handle fetch parameters such as unreadOnly and page size.
    /// - Parameters:
    ///   - page: page number to fetch
    /// - Returns: requested page of items
    private func fetchPage(page: Int) async throws -> [Item] {
        assertionFailure("This method must be implemented by the child tracker")
        return []
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
    
    /// Adds the given items to the items array
    /// - Parameter toAdd: items to add
    private func add(toAdd: [Item]) {
        items.append(contentsOf: toAdd)
    }
    
    /// Clears the tracker to an empty state.
    /// **WARNING:**
    /// **DO NOT** call this method from anywhere but loadPage! This is *purely* a helper function for loadPage and *will* lead to unexpected behavior if called elsewhere!
    private func clear() {
        print("clearing messages tracker")
        ids = .init(minimumCapacity: 1000)
        items = .init()
        page = 0
    }
}

// child tracker types:
// parent type: must be sortable
// underlying type: must be convertable to parent type

// parent tracker types:
// self type: must be sortable
// child types: must be convertable to parent type
