//
//  CorePostFeedLoader.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2026-01-05.
//

import Foundation
import Nuke
import Observation

@Observable
public class PostFetcher: Fetcher<Post> {
    var sortType: PostSortType
    
    init(api: ApiClient, sortType: PostSortType, pageSize: Int) {
        self.sortType = sortType
        
        super.init(api: api, pageSize: pageSize)
    }
    
    override func fetchPage(_ page: Int) async throws -> FetchResponse {
        let result = try await getPosts(page: page, cursor: nil)

        return .init(
            items: result.posts,
            prevCursor: nil,
            nextCursor: result.cursor
        )
    }
    
    override func fetchCursor(_ cursor: String) async throws -> FetchResponse {
        let result = try await getPosts(page: 1, cursor: cursor)
        
        return .init(
            items: result.posts,
            prevCursor: cursor,
            nextCursor: result.cursor
        )
    }
    
    func getPosts(page: Int, cursor: String?) async throws -> (posts: [Post], cursor: String?) {
        preconditionFailure("This method must be implemented by the inheriting class")
    }
}

/// Post tracker for use with single feeds. Can easily be extended to load any pure post feed by creating an inheriting class that overrides getPosts().
@Observable
public class CorePostFeedLoader: PrefetchingFeedLoader<Post> {
    // store reference to the filter used by the LoadingActor so we can modify its filterContext from changeApi
    var filter: PostFilter
    
    init(
        showReadPosts: Bool,
        filterContext: FilterContext,
        prefetchingConfiguration: PrefetchingConfiguration,
        fetcher: Fetcher<Post>
    ) {
        let filter: PostFilter = .init(showRead: showReadPosts, context: filterContext)
        self.filter = filter
        
        super.init(
            filter: filter,
            prefetchingConfiguration: prefetchingConfiguration,
            fetcher: fetcher
        )
    }
    
    // MARK: Custom Behavior

    override public func changeApi(to newApi: ApiClient, context: FilterContext) async {
        filter.updateContext(to: context)
        await fetcher.changeApi(to: newApi, context: context)
    }
}
