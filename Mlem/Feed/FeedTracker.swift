//
//  FeedTracker.swift
//  Mlem
//
//  Created by mormaer on 28/06/2023.
//
//

import Foundation

class FeedTracker<Item: FeedTrackerItem>: ObservableObject {

    @Published private(set) var isLoading: Bool = true
    @Published private(set) var items: [Item]

    private(set) var page: Int = 1

    private var ids: Set<Item.UniqueIdentifier> = .init(minimumCapacity: 1_000)
    private var thresholdOffset: Int = -10
    private let shouldPerformMergeSorting: Bool

    init(shouldPerformMergeSorting: Bool = true, initialItems: [Item] = .init()) {
        self.shouldPerformMergeSorting = shouldPerformMergeSorting
        items = initialItems
    }

    // MARK: - Public methods

    /// A method to determine if the tracker should load more items
    /// - Parameter item: The `Item` which is being displayed to the user
    /// - Returns: A `Bool` indicating if more items should be loaded
    @MainActor func shouldLoadContent(after item: Item) -> Bool {
        guard !isLoading else {
            return false
        }

        let thresholdIndex = items.index(items.endIndex, offsetBy: thresholdOffset)
        if thresholdIndex >= 0,
           let itemIndex = items.firstIndex(where: { $0.uniqueIdentifier == item.uniqueIdentifier }),
           itemIndex >= thresholdIndex {
            return true
        }

        return false
    }

    /// A method to perform a request to retrieve  tracker items
    /// - Parameter request: An `APIRequest` that conforms to `FeedItemProviding` with an `Item` type that matches this trackers generic type
    /// - Returns: The `Response` type of the request as a discardable result
    @discardableResult func perform<Request: APIRequest>(
        _ request: Request,
        filtering: @escaping (_: Request.Response.Item) -> Bool = { _ in true}
    ) async throws -> Request.Response where Request.Response: FeedTrackerItemProviding, Request.Response.Item == Item {
        let response = try await retrieveItems(with: request)

        add(response.items, filtering: filtering)
        page += 1

        return response
    }

    /// A method to refresh this tracker, this will reset the state of the tracker to it's first page and set the retrieved items when returned
    /// - Parameter request: An `APIRequest` that conforms to `FeedItemProviding` with an `Item` type that matches this trackers generic type
    /// - Returns: The `Response` type of the request as a discardable result
    @discardableResult func refresh<Request: APIRequest>(
        _ request: Request,
        filtering: @escaping (_: Request.Response.Item) -> Bool = { _ in true }
    ) async throws -> Request.Response where Request.Response: FeedTrackerItemProviding, Request.Response.Item == Item {
        let response = try await retrieveItems(with: request)
        await reset(with: response.items)
        return response
    }

    /// A method to add new items into the tracker, duplicate items will be rejected
    /// - Parameter newItems: The array of new `Item`'s you wish to add
    func add(_ newItems: [Item], filtering: @escaping (_: Item) -> Bool = { _ in true}) {
        let accepted = dedupedItems(from: newItems.filter(filtering))
        if !shouldPerformMergeSorting {
            RunLoop.main.perform { [self] in
                items.append(contentsOf: accepted)
            }
            return
        }

        let merged =  merge(arr1: items, arr2: accepted, compare: { $0.published > $1.published })
        RunLoop.main.perform { [self] in
            items = merged
        }
    }

    /// A method to add an item  to the start of the current list of items
    /// - Parameter newItem: The `Item` you wish to add
    @MainActor func prepend(_ newItem: Item) {
        guard ids.insert(newItem.uniqueIdentifier).inserted else {
            return
        }

        items.prepend(newItem)
    }

    /// A method to supply an updated item to the tracker
    ///  - Note: If the `id` of the item is not already in the tracker the `updatedItem` will be discarded
    /// - Parameter updatedItem: An updated `Item`
    @MainActor func update(with updatedItem: Item) {
        guard let index = items.firstIndex(where: { $0.uniqueIdentifier == updatedItem.uniqueIdentifier }) else {
            return
        }

        items[index] = updatedItem
    }

    // MARK: - Private methods

    /// A method to reset the tracker to it's initial state
    @MainActor private func reset(
        with newItems: [Item] = .init(),
        filteredWith filter: @escaping (_: Item) -> Bool = { _ in true }
    ) {
        page = newItems.isEmpty ? 1 : 2
        ids = .init(minimumCapacity: 1_000)
        items = dedupedItems(from: newItems.filter(filter))
    }

    @MainActor
    private func retrieveItems<Request: APIRequest>(
        with request: Request
    ) async throws -> Request.Response where Request.Response: FeedTrackerItemProviding, Request.Response.Item == Item {
        defer { isLoading = false }
        isLoading = true
        return try await APIClient().perform(request: request)
    }

    private func dedupedItems(from newItems: [Item]) -> [Item] {
        let accepted = newItems.filter { ids.insert($0.uniqueIdentifier).inserted }
        return accepted
    }
    
    // Takes a callback and fillters out any entry that returns false
    //
    // Returns the number of entries removed
    @discardableResult func filter(_ callback: (Item) -> Bool) -> Int {
        var removedElements = 0
        
        items = items.filter({
            let filterResult = callback($0)
            
            // Remove the ID from the IDs set as well
            if !filterResult {
                ids.remove($0.uniqueIdentifier)
                removedElements += 1
            }
            return filterResult
        })
        
        return removedElements
    }
}
