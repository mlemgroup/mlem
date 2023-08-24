//
//  Post Tracker.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-08-24.
//

import Foundation

/**
 New post tracker built on top of the PostRepository instead of calling the API directly. Because this thing works fundamentally differently from the old one, it can't conform to FeedTracker--that's going to need a revamp down the line once everything uses nice shiny middleware models, so for now we're going to have to put up with some ugly
 */
class PostTrackerNew: ObservableObject {
    // behavior governors
    private let shouldPerformMergeSorting: Bool
    private let internetSpeed: InternetSpeed
    
    // state drivers
    @Published var items: [PostModel]
    
    // utility
    private var ids: Set<ContentModelIdentifier> = .init(minimumCapacity: 1000)
    private(set) var isLoading: Bool = true // accessible but not published because it causes lots of bad view redraws
    
    init(
        shouldPerformMergeSorting: Bool = true,
        internetSpeed: InternetSpeed,
        initialItems: [PostModel] = .init()
    ) {
        self.shouldPerformMergeSorting = shouldPerformMergeSorting
        self.internetSpeed = internetSpeed
        self.items = initialItems
    }
    
    /**
     Determines whether the tracker should load more items
     
     NOTE: this is equivalent to the old shouldLoadContentPreciselyAfter
     */
    @MainActor func shouldLoadContentAfter(after item: PostModel) -> Bool {
        guard !isLoading else { return false }
        
        let thresholdIndex = max(0, items.index(items.endIndex, offsetBy: AppConstants.infiniteLoadThresholdOffset))
        if thresholdIndex >= 0,
           let itemIndex = items.firstIndex(where: { $0.id == item.id }),
           itemIndex >= thresholdIndex {
            return true
        }
        
        return false
    }
}
