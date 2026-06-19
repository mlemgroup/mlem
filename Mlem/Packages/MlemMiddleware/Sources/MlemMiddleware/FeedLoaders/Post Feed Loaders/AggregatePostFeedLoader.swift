//
//  AggregatePostFeedLoader.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2026-01-05.
//

import Foundation

@Observable
class AggregatePostFetcher: PostFetcher {
    var feedType: ListingType
    let contentFilter: GetContentFilter?
    
    init(api: ApiClient, feedType: ListingType, sortType: PostSortType, pageSize: Int, contentFilter: GetContentFilter?) {
        self.feedType = feedType
        self.contentFilter = contentFilter
        
        super.init(api: api, sortType: sortType, pageSize: pageSize)
    }
    
    override func fetchContent(_ pageInfo: PageInfo) async throws -> PagedResponse<Post> {
        try await api.getPosts(
            feed: feedType,
            pageInfo: pageInfo,
            sort: sortType,
            filter: contentFilter,
            showHidden: false // TODO:
        )
    }
}

public class AggregatePostFeedLoader: CorePostFeedLoader {
    // force unwrap because this should ALWAYS be an AggregatePostFetcher
    var aggregatePostFetcher: AggregatePostFetcher { fetcher as! AggregatePostFetcher }
    
    // force unwrap because this should ALWAYS be a PostFetcher
    private var postFetcher: PostFetcher { fetcher as! PostFetcher }
        
    public var feedType: ListingType { aggregatePostFetcher.feedType }
    public var sortType: PostSortType { postFetcher.sortType }
    
    public init(
        pageSize: Int,
        sortType: PostSortType,
        showReadPosts: Bool,
        filterContext: FilterContext,
        prefetchingConfiguration: PrefetchingConfiguration,
        urlCache: URLCache,
        api: ApiClient,
        feedType: ListingType,
        contentFilter: GetContentFilter? = nil
    ) {
        super.init(
            showReadPosts: showReadPosts,
            filterContext: filterContext,
            prefetchingConfiguration: prefetchingConfiguration,
            fetcher: AggregatePostFetcher(
                api: api,
                feedType: feedType,
                sortType: sortType,
                pageSize: pageSize,
                contentFilter: contentFilter
            )
        )
    }
    
    @MainActor
    public func changeFeedType(to newFeedType: ListingType) async throws {
        let shouldRefresh = items.isEmpty || aggregatePostFetcher.feedType != newFeedType
        
        // always perform assignment--if account changed, feed type will look unchanged but API will be different
        aggregatePostFetcher.feedType = newFeedType
        
        // only refresh if nominal feed type changed
        if shouldRefresh {
            try await refresh(clearBeforeRefresh: true)
        }
    }
    
    /// Changes the post sort type to the specified value and reloads the feed
    public func changeSortType(to newSortType: PostSortType, forceRefresh: Bool = false) async throws {
        // don't do anything if sort type not changed
        guard postFetcher.sortType != newSortType || forceRefresh else {
            return
        }
        
        postFetcher.sortType = newSortType
        try await refresh(clearBeforeRefresh: true)
    }
}
