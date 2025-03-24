//
//  PersonContentStream.swift
//
//
//  Created by Eric Andrews on 2024-07-21.
//

import CollectionConcurrencyKit
import Foundation
import Nuke

// This struct is just a convenience wrapper to handle stream state--all loading operations happen at the FeedLoader level to
// avoid parent/child concurrency control hell
public class PersonContentStream<Item: PersonContentProviding> {
    // From the frontend it is more ergonomic to have these be PersonContent. These are guaranteed to all be of type Item by
    // guarding assignment behind `init` and `addItems`, which can only take Item.
    private(set) var items: [PersonContent]
    var cursor: Int = 0
    var doneLoading: Bool = false
    var thresholds: Thresholds<PersonContent>
    var prefetchingConfiguration: PrefetchingConfiguration
    
    init(items: [Item]? = nil, prefetchingConfiguration: PrefetchingConfiguration) {
        self.prefetchingConfiguration = prefetchingConfiguration
        self.thresholds = .init()
        if let items {
            let personContentItems: [PersonContent] = items.map(\.userContent)
            self.items = personContentItems
            thresholds.update(with: personContentItems)
        } else {
            self.items = .init()
        }
    }
    
    var needsMoreItems: Bool { !doneLoading && cursor >= items.count }
    
    func reset() {
        items = .init()
        cursor = 0
        doneLoading = false
        thresholds = .init()
    }
    
    func addItems(_ newItems: [Item]) {
        let personContentItems: [PersonContent] = newItems.map(\.userContent)
        preloadImages(personContentItems)
        items.append(contentsOf: personContentItems)
        thresholds.update(with: personContentItems)
        if newItems.isEmpty {
            doneLoading = true
        }
    }
    
    /// Gets the sort value of the next item in stream for a given sort type without affecting the cursor. Assumes loading has been handled by the FeedLoader.
    /// - Returns: sorting value of the next tracker item corresponding to the given sort type
    /// - Warning: This is NOT a thread-safe function! Only one thread at a time per stream may call this function!
    func nextItemSortVal(sortType: FeedLoaderSort.SortType) async throws -> FeedLoaderSort? {
        guard cursor < items.count else {
            return nil
        }
        
        return items[safeIndex: cursor]?.sortVal(sortType: sortType)
    }
    
    /// Gets the next item in the stream and increments the cursor
    /// - Returns: next item in the feed stream
    /// - Warning: This is NOT a thread-safe function! Only one thread at a time per stream may call this function!
    func consumeNextItem() -> PersonContent? {
        guard cursor < items.count else {
            return nil
        }
        
        cursor += 1
        return items[cursor - 1]
    }
    
    /// Preloads images for the given PersonContent items
    func preloadImages(_ items: [PersonContent]) {
        Task {
            // TODO: prefetch comment images
            let posts = items.compactMap { item in
                switch item.wrappedValue {
                case let .post(post):
                    return post
                default: return nil
                }
            }
            
            await prefetchingConfiguration.prefetcher.startPrefetching(with: posts.concurrentFlatMap { post -> [ImageRequest] in
                await post.imageRequests(configuration: self.prefetchingConfiguration)
            })
        }
    }
}
