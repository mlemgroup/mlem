//
//  StandardFeedLoader.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-10-15.
//

import Foundation
import Observation
import os
import Semaphore

@Observable
public class StandardFeedLoader<Item: FeedLoadable>: FeedLoading {
    let log: Logger = .mlemLogger()
    
    public internal(set) var items: [Item] = .init()
    public internal(set) var loadingState: FeedLoadingState = .initial
    private(set) var thresholds: Thresholds<Item> = .init()
    
    let fetcher: Fetcher<Item>
    var loadingActor: LoadingActor<Item>

    init(filter: MultiFilter<Item>, fetcher: Fetcher<Item>) {
        self.fetcher = fetcher
        self.loadingActor = .init(fetcher: fetcher, filter: filter)
    }

    // MARK: - State Modification Methods
    
    /// Updates the loading state
    @MainActor
    func setLoading(_ newState: FeedLoadingState) {
        loadingState = newState
        log.debug("[\(Self.self)] set loading state to \(String(describing: newState))")
    }
    
    /// Sets the items to a new array
    @MainActor
    func setItems(_ newItems: [Item]) {
        processNewItems(newItems)
        items = newItems
        thresholds.update(with: newItems)
    }
    
    /// Adds the given items to the items array
    /// - Parameter toAdd: items to add
    @MainActor
    func addItems(_ newItems: [Item]) async {
        processNewItems(newItems)
        items.append(contentsOf: newItems)
        thresholds.update(with: newItems)
    }
    
    @MainActor
    public func prependItem(_ newItem: Item) {
        items.prepend(newItem)
        
        // filter the item on a background thread for deduping
        Task {
            await loadingActor.filterItem(newItem)
        }
    }
    
    // MARK: - External methods

    /// If the given item is the loading threshold item, loads more content
    /// This should be called as an .onAppear of every item in a feed that should support infinite scrolling
    public func loadIfThreshold(_ item: Item) throws {
        if loadingState == .idle, thresholds.isThreshold(item) {
            // this is a synchronous function that wraps the loading as a task so that the task is attached to the loader itself, not the view that calls it, and is therefore safe from being cancelled by view redraws
            Task(priority: .userInitiated) {
                try await loadMoreItems()
            }
        }
    }
    
    /// Loads the next page of items. Returns when more items have been added to the items array or loading is complete, even
    /// if called while another load is underway
    public func loadMoreItems() async throws {
        try await loadMoreItems(overwriteExistingItems: false)
    }
    
    /// Internal loadMoreItems() that allows overwriting existing items, used to back refresh
    func loadMoreItems(overwriteExistingItems: Bool) async throws {
        await setLoading(.loading)
  
        try await loadingActor.load { response in
            var newItems: [Item]?
            var newState: FeedLoadingState
            
            switch response {
            case let .success(items):
                newItems = items
                newState = items.count > 0 ? .idle : .done
            case let .done(items):
                newItems = items
                newState = .done
            case .ignored, .cancelled:
                self.log.info("[\(Self.self)] load did not complete (\(response.description))")
                newState = .idle
            }
            
            if let newItems {
                if overwriteExistingItems {
                    await self.setItems(newItems)
                } else {
                    await self.addItems(newItems)
                }
            }
            
            await self.setLoading(newState)
            self.log.info("[\(Self.self)] loadMoreItems complete")
        }
    }
    
    public func refresh(clearBeforeRefresh: Bool) async throws {
        await setLoading(.loading)
        
        if clearBeforeRefresh {
            await setItems(.init())
        }
        
        await loadingActor.reset()
    
        try await loadMoreItems(overwriteExistingItems: true)
    }

    public func clear() async {
        await loadingActor.reset()
        await setItems(.init())
        await setLoading(.idle)
    }
    
    /// Helper function to perform custom post-fetch processing (e.g., prefetching). Override to implement desired behavior.
    func processNewItems(_ items: [Item]) {}
    
    /// Adds a filter to the tracker, removing all current items that do not pass the filter and filtering out all future items that do not pass the filter.
    /// Use in situations where filtering is handled client-side (e.g., keywords)
    /// - Parameter newFilter: Item.FilterType describing the filter to apply
    public func activateFilter(_ target: Item.FilterType) async throws {
        try await loadingActor.activateFilter(target) {
            await setItems(loadingActor.filter.reset(with: items))
            
            if items.isEmpty {
                try await refresh(clearBeforeRefresh: false)
            } else if thresholds.fallback == nil {
                // if too few items are present after filtering to trigger threshold loading, initiate new load
                try await loadMoreItems()
            }
        }
    }
    
    public func deactivateFilter(_ target: Item.FilterType) async throws {
        try await loadingActor.deactivateFilter(target) {
            try await refresh(clearBeforeRefresh: true)
        }
    }
    
    public func getFilteredCount(for toCount: Item.FilterType) async -> Int {
        await loadingActor.filter.numFiltered(for: toCount)
    }
    
    public func changeApi(to newApi: ApiClient, context: FilterContext) async {
        await fetcher.changeApi(to: newApi, context: context)
    }
}
