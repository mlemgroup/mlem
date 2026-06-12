//
//  SearchPostFeedLoader.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 04/10/2024.
//

import Foundation

@Observable
public class SearchPostFetcher: Fetcher<Post> {
    public var query: String
    public var communityId: Int?
    public var creatorId: Int?
    
    public var listing: ListingType
    
    public var sortType: PostSortType

    // setters to allow manual overriding of these for search use cases
    override public func changeApi(to newApi: ApiClient, context: FilterContext) async {
        await super.changeApi(to: newApi, context: context)
    }

    public func setSortType(_ sortType: PostSortType) { self.sortType = sortType }
    
    init(
        api: ApiClient,
        sortType: PostSortType,
        pageSize: Int,
        query: String,
        communityId: Int?,
        creatorId: Int?,
        listing: ListingType
    ) {
        self.query = query
        self.communityId = communityId
        self.creatorId = creatorId
        self.listing = listing
        self.sortType = sortType
        
        super.init(api: api, pageSize: pageSize)
    }
    
    override func fetchContent(_ pageInfo: PageInfo) async throws -> PagedResponse<Post> {
        try await api.searchPosts(
            query: query,
            pageInfo: pageInfo,
            communityId: communityId,
            creatorId: creatorId,
            filter: listing,
            sort: sortType
        )
    }
}

public class SearchPostFeedLoader: CorePostFeedLoader {
    // force unwrap because this should ALWAYS be a SearchPostFetcher
    public var searchPostFetcher: SearchPostFetcher { fetcher as! SearchPostFetcher }
    
    public init(
        api: ApiClient,
        query: String = "",
        pageSize: Int = 20,
        sortType: PostSortType,
        creatorId: Int? = nil,
        communityId: Int? = nil,
        prefetchingConfiguration: PrefetchingConfiguration,
        urlCache: URLCache,
        listing: ListingType = .all
    ) {
        super.init(
            showReadPosts: true,
            filterContext: .none(), // search doesn't filter, only obscures on the frontend
            prefetchingConfiguration: prefetchingConfiguration,
            fetcher: SearchPostFetcher(
                api: api,
                sortType: sortType,
                pageSize: pageSize,
                query: query,
                communityId: communityId,
                creatorId: creatorId,
                listing: listing
            )
        )
    }
}
