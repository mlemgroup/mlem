//
//  MultiFetcher.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2024-11-24.
//

import Observation

@Observable
class MultiFetcher<Item: FeedLoadable>: Fetcher<Item> {
    var sources: [ChildFeedLoader<Item>]
    var sortType: FeedLoaderSort.SortType
    
    init(api: ApiClient, pageSize: Int, sources: [ChildFeedLoader<Item>], sortType: FeedLoaderSort.SortType) {
        self.sources = sources
        self.sortType = sortType
        
        super.init(api: api, pageSize: pageSize)
    }
    
    override func fetch() async throws -> LoadingResponse<Item> {
        var newItems: [Item] = .init()
        
        while newItems.count < pageSize {
            if let nextItem = try await computeNextItem() {
                newItems.append(nextItem)
            } else {
                print("[\(Self.self)] no next item found")
                return .done(newItems)
            }
        }
        
        return .success(newItems)
    }
    
    override func reset() async {
        for source in sources {
            await source.clear(clearParent: false)
            print("[\(Self.self)] source cleared (\(source.loadingState))")
        }
        
        await super.reset()
    }
    
    /// Computes and returns the highest sorted item from the tops of all sources
    private func computeNextItem() async throws -> Item? {
        var sortVal: FeedLoaderSort?
        var sourceToConsume: ChildFeedLoader<Item>?
        
        // find the highest-sorted item from the tops of all sources
        for source in sources {
            (sortVal, sourceToConsume) = try await compareNextItem(lhsVal: sortVal, lhsSource: sourceToConsume, rhsSource: source)
        }
        
        return sourceToConsume?.consumeNextItem()
    }
    
    private func compareNextItem(
        lhsVal: FeedLoaderSort?,
        lhsSource: ChildFeedLoader<Item>?,
        rhsSource: ChildFeedLoader<Item>
    ) async throws -> (FeedLoaderSort?, ChildFeedLoader<Item>?) {
        // if no next item on rhs, return lhs (even if null)
        guard let rhsVal = try await rhsSource.nextItemSortVal(sortType: sortType) else {
            return (lhsVal, lhsSource)
        }
        
        // if no lhsVal, rhs next by default
        guard let lhsVal else {
            return (rhsVal, rhsSource)
        }
        
        return lhsVal > rhsVal ? (lhsVal, lhsSource) : (rhsVal, rhsSource)
    }
    
    override func changeApi(to newApi: ApiClient, context: FilterContext) async {
        for source in sources {
            await source.changeApi(to: newApi, context: context)
        }
        
        await super.changeApi(to: newApi, context: context)
    }
}
