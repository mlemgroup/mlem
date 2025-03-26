//
//  ChildFeedLoader.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2024-11-24.
//

/// Helper class bundling a parent feed loader and a position in a ChildFeedLoader's item list
class FeedLoaderStream {
    weak var parent: (any FeedLoading)?
    var cursor: Int
    
    init(parent: (any FeedLoading)? = nil) {
        self.parent = parent
        self.cursor = 0
    }
}

public class ChildFeedLoader<Item: FeedLoadable>: StandardFeedLoader<Item> {
    var stream: FeedLoaderStream?
    var sortType: FeedLoaderSort.SortType
    
    init(filter: MultiFilter<Item>, fetcher: Fetcher<Item>, sortType: FeedLoaderSort.SortType) {
        self.sortType = sortType
        
        super.init(filter: filter, fetcher: fetcher)
    }
    
    public func setParent(parent: any FeedLoading<Item>) {
        stream = .init(parent: parent)
    }
    
    public func nextItemSortVal(sortType: FeedLoaderSort.SortType) async throws -> FeedLoaderSort? {
        assert(sortType == self.sortType, "Conflicting types for sortType! This will lead to unexpected sorting behavior.")
        
        guard let stream, stream.parent != nil else {
            print("[\(Self.self)] could not find stream or parent")
            return nil
        }
        
        if stream.cursor < items.count {
            return items[safeIndex: stream.cursor]?.sortVal(sortType: sortType)
        } else {
            if loadingState == .done {
                print("[\(Self.self)] done loading")
                return nil
            }
            
            print("[\(Self.self)] out of items (\(items.count)), loading more")
            try await loadMoreItems()
            
            if stream.cursor >= items.count {
                // NOTE: this assertion can sometimes be tripped by spamming the filter button
                assert(loadingState == .done, "[\(Item.self) ChildFeedLoader] Invalid loading state \(loadingState)")
                return nil
            }
            
            print("[\(Self.self)] fetched more items (\(items.count))")
            return items[stream.cursor].sortVal(sortType: sortType)
        }
    }
    
    public func consumeNextItem() -> Item? {
        guard let stream, stream.parent != nil else {
            assertionFailure("[\(Item.self)] could not find stream or parent")
            return nil
        }
        
        stream.cursor += 1
        return items[safeIndex: stream.cursor - 1]
    }
    
    public func clear(clearParent: Bool) async {
        if clearParent {
            await stream?.parent?.clear()
        }
        
        stream?.cursor = 0
        await super.clear()
    }
}
