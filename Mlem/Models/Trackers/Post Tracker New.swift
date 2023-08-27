//
//  Post Tracker New.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-08-26.
//

import Foundation
import Nuke
import SwiftUI

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
    private(set) var page: Int = 1
    
    // prefetching
    private let prefetcher = ImagePrefetcher(
        pipeline: ImagePipeline.shared,
        destination: .memoryCache,
        maxConcurrentRequestCount: 40
    )
    
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
    
    @MainActor
    func add(_ newItems: [PostModel], filtering: @escaping (_: PostModel) -> Bool = { _ in true }) {
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
    
    // MARK: - Private methods
    
    /**
     Filters a list of PostModels to only those PostModels not present in ids. Updates ids.
     */
    private func dedupedItems(from newItems: [PostModel]) -> [PostModel] {
        return newItems.filter { ids.insert($0.id).inserted }
    }
}
