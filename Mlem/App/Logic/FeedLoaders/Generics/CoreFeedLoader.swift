//
//  CoreFeedLoader.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-22.
//

import Foundation
import SwiftUI

/// Class providing common feed loading functionality for StandardFeedLoader and ParentFeedLoader
@Observable
class CoreFeedLoader<Item: FeedLoadable> {
    var items: [Item] = .init()
    private(set) var loadingState: LoadingState = .idle
    
    // uids of items that should trigger loading. threshold is several items before the end, to give the illusion of infinite loading. fallbackThreshold is the last item in feed, and exists to catch loading if the user scrolled too fast to trigger threshold
    private(set) var threshold: ContentModelIdentifier?
    private(set) var fallbackThreshold: ContentModelIdentifier?
    
    private(set) var internetSpeed: InternetSpeed

    init(internetSpeed: InternetSpeed) {
        self.internetSpeed = internetSpeed
    }
    
    /// If the given item is the loading threshold item, loads more content
    /// This should be called as an .onAppear of every item in a feed that should support infinite scrolling
    func loadIfThreshold(_ item: Item) {
        if loadingState == .idle, item.uid == threshold || item.uid == fallbackThreshold {
            // this is a synchronous function that wraps the loading as a task so that the task is attached to the loader itself, not the view that calls it, and is therefore safe from being cancelled by view redraws
            Task(priority: .userInitiated) {
                await loadMoreItems()
            }
        }
    }
    
    func loadMoreItems() async {
        preconditionFailure("This method must be overridden by the inheriting class")
    }
    
    /// Updates the loading state
    @MainActor
    func setLoading(_ newState: LoadingState) {
        loadingState = newState
    }
    
    /// Sets the items to a new array
    @MainActor
    func setItems(_ newItems: [Item]) {
        items = newItems
        updateThresholds()
    }
    
    /// Adds the given items to the items array
    /// - Parameter toAdd: items to add
    @MainActor
    func addItems(_ newItems: [Item]) async {
        items.append(contentsOf: newItems)
        updateThresholds()
    }
    
    @MainActor
    func prependItem(_ newItem: Item) async {
        items.prepend(newItem)
    }
    
    private func updateThresholds() {
        if items.isEmpty {
            threshold = nil
        } else {
            let thresholdIndex = max(0, items.count + AppConstants.infiniteLoadThresholdOffset)
            threshold = items[thresholdIndex].uid
            fallbackThreshold = items.last?.uid
        }
    }
}
