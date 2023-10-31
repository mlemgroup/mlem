//
//  CoreTracker.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-10-31.
//

import Foundation

/// Class providing common tracker functionality for BasicTracker and ParentTracker
class CoreTracker<Item: TrackerItem>: ObservableObject {
    @Published var items: [Item] = .init()
    @Published private(set) var loadingState: LoadingState = .idle
    
    private(set) var threshold: ContentModelIdentifier?
    private(set) var internetSpeed: InternetSpeed
    private(set) var sortType: TrackerSortType
    
    init(internetSpeed: InternetSpeed, sortType: TrackerSortType) {
        self.internetSpeed = internetSpeed
        self.sortType = sortType
    }
    
    /// If the given item is the loading threshold item, loads more content
    /// This should be called as an .onAppear of every item in a feed that should support infinite scrolling
    func loadIfThreshold(_ item: Item) {
        if loadingState != .done, item.uid == threshold {
            // this is a synchronous function that wraps the loading as a task so that the task is attached to the tracker itself, not the view that calls it, and is therefore safe from being cancelled by view redraws
            Task(priority: .userInitiated) {
                await loadNextPage()
            }
        }
    }
    
    func loadNextPage() async {
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
        updateThreshold()
    }
    
    /// Adds the given items to the items array
    /// - Parameter toAdd: items to add
    @MainActor
    func addItems(_ newItems: [Item]) async {
        items.append(contentsOf: newItems)
        updateThreshold()
    }
    
    private func updateThreshold() {
        if items.isEmpty {
            threshold = nil
        } else {
            let thresholdIndex = max(0, items.count + AppConstants.infiniteLoadThresholdOffset)
            threshold = items[thresholdIndex].uid
        }
    }
}
