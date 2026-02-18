//
//  CommunityPostFeedLoader.swift
//
//
//  Created by Eric Andrews on 2024-07-07.
//

import Foundation

@Observable
class CommunityPostFetcher: PostFetcher {
    var community: Community
    
    init(sortType: PostSortType, pageSize: Int, community: Community) {
        self.community = community
        
        super.init(api: community.api, sortType: sortType, pageSize: pageSize)
    }
    
    override func getPosts(page: Int, cursor: String?) async throws -> (posts: [Post], cursor: String?) {
        try await community.getPosts(
            sort: sortType,
            page: page,
            cursor: cursor,
            limit: pageSize,
            filter: nil, // TODO:
            showHidden: false // TODO:
        )
    }
}

public class CommunityPostFeedLoader: CorePostFeedLoader {
    public var community: Community
    
    var communityPostFetcher: CommunityPostFetcher { fetcher as! CommunityPostFetcher }
    
    // force unwrap because this should ALWAYS be a PostFetcher
    private var postFetcher: PostFetcher { fetcher as! PostFetcher }
    
    public var sortType: PostSortType { postFetcher.sortType }

    public init(
        pageSize: Int,
        sortType: PostSortType,
        showReadPosts: Bool,
        filterContext: FilterContext,
        prefetchingConfiguration: PrefetchingConfiguration,
        urlCache: URLCache,
        community: Community
    ) {
        self.community = community
        super.init(
            showReadPosts: showReadPosts,
            filterContext: filterContext,
            prefetchingConfiguration: prefetchingConfiguration,
            fetcher: CommunityPostFetcher(sortType: sortType, pageSize: pageSize, community: community)
        )
    }
    
    override public func changeApi(to newApi: ApiClient, context: FilterContext) async {
        do {
            let resolvedCommunity = try await newApi.resolve(url: community.actorId.url)
            
            guard let newCommunity = resolvedCommunity as? Community else {
                assertionFailure("Did not get community back")
                return
            }
            
            filter.updateContext(to: context)
            communityPostFetcher.community = newCommunity
        } catch {
            assertionFailure("Couldn't change API")
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
