//
//  FeedTracking.swift
//  Mlem
//
//  Created by mormaer on 03/09/2023.
//
//

import Foundation

protocol FeedTracking: ObservableObject {
    associatedtype Item: FeedTrackerItem
    
    var isLoading: Bool { get }
    var items: [Item] { get set }
    var ids: Set<Item.UniqueIdentifier> { get set }
    var page: Int { get set }
    var shouldPerformMergeSorting: Bool { get }
    var internetSpeed: InternetSpeed { get }
    
    func loadNextPage() async throws
    func refresh(clearBeforeFetch: Bool) async throws
    func retrieveItems(for page: Int) async throws -> [Item]
    
    func shouldLoadContent(after item: Item) -> Bool
    func shouldLoadContentPrecisely(after item: Item) -> Bool
    
    func add(_ newItems: [Item], filtering: @escaping (Item) -> Bool)
    func prepend(_ newItem: Item)
    func update(with updatedItem: Item)
    
    func filter(_ predicate: (Item) -> Bool) -> Int
}

extension FeedTracking {
    @MainActor
    func loadNextPage() async throws {
        let items = try await retrieveItems(for: page)
        add(items, filtering: { _ in true })
        page += 1
    }
    
    @MainActor
    func refresh(clearBeforeFetch: Bool = false) async throws {
        if clearBeforeFetch {
            reset()
        }
        
        let items = try await retrieveItems(for: 1)
        reset(with: items)
    }
    
    /// A method to determine if the tracker should load more items
    /// - Parameter item: The `Item` which is being displayed to the user
    /// - Returns: A `Bool` indicating if more items should be loaded
    @MainActor func shouldLoadContent(after item: Item) -> Bool {
        guard !isLoading else {
            return false
        }

        let thresholdIndex = items.index(items.endIndex, offsetBy: AppConstants.infiniteLoadThresholdOffset)
        if thresholdIndex >= 0,
           let itemIndex = items.firstIndex(where: { $0.uniqueIdentifier == item.uniqueIdentifier }),
           itemIndex >= thresholdIndex {
            return true
        }

        return false
    }
    
    /// This method is equivalent to `shouldLoadContent(after: ...)` except will only return `true` where the passed in `Item` *is* the threshold item
    /// - Parameter item: The `Item` which is being displayed to the user
    /// - Returns: A `Bool` indicating if more items should be loaded
    @MainActor func shouldLoadContentPrecisely(after item: Item) -> Bool {
        guard !isLoading else { return false }
        
        let thresholdIndex = max(0, items.index(items.endIndex, offsetBy: AppConstants.infiniteLoadThresholdOffset))
  
        if let itemIndex = items.firstIndex(where: { $0.uniqueIdentifier == item.uniqueIdentifier }),
           itemIndex == thresholdIndex {
            return true
        }

        return false
    }
    
    /// A method to add new items into the tracker, duplicate items will be rejected
    /// - Parameter newItems: The array of new `Item`'s you wish to add
    @MainActor
    func add(_ newItems: [Item], filtering: @escaping (_: Item) -> Bool = { _ in true }) {
        let accepted = dedupedItems(from: newItems.filter(filtering))
        if !shouldPerformMergeSorting {
            RunLoop.main.perform { [self] in
                items.append(contentsOf: accepted)
            }
            return
        }

        let merged = merge(arr1: items, arr2: accepted, compare: { $0.published > $1.published })
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
    
    private func dedupedItems(from newItems: [Item]) -> [Item] {
        let accepted = newItems.filter { ids.insert($0.uniqueIdentifier).inserted }
        return accepted
    }
    
    /// A method to reset the tracker to it's initial state
    @MainActor private func reset(
        with newItems: [Item] = .init(),
        filteredWith filter: @escaping (_: Item) -> Bool = { _ in true }
    ) {
        page = newItems.isEmpty ? 1 : 2
        ids = .init(minimumCapacity: 1000)
        items = dedupedItems(from: newItems.filter(filter))
    }
    
    /// A method to filter items from the tracker
    /// - Parameter predicate: The operation to use when filtering
    /// - Returns: The number of items removed by the filter operation
    @discardableResult func filter(_ predicate: (Item) -> Bool) -> Int {
        var removedElements = 0
        
        items = items.filter {
            let filterResult = predicate($0)
            
            // Remove the id from the ids set as well
            if !filterResult {
                ids.remove($0.uniqueIdentifier)
                removedElements += 1
            }
            return filterResult
        }
        
        return removedElements
    }
}
