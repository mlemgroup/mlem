//
//  SearchPostFeedLoader.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 04/10/2024.
//

import Foundation

@Observable
public class SearchPostFetcher: Fetcher<Post> {
    public enum SortType {
        case v4(SearchSortType)
        case v3(PostSortType)
    }
    
    public var query: String
    public var communityId: Int?
    public var creatorId: Int?
    
    public var listing: ListingType
    
    public var sortType: SortType

    // setters to allow manual overriding of these for search use cases
    override public func changeApi(to newApi: ApiClient, context: FilterContext) async {
        await super.changeApi(to: newApi, context: context)
    }

    public func setSortType(_ sortType: SortType) { self.sortType = sortType }
    
    init(
        api: ApiClient,
        sortType: SortType,
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
    
    override func fetchPage(_ page: Int) async throws -> Fetcher<Post>.FetchResponse {
        let response: [Post]
        switch sortType {
        case let .v4(searchSortType):
            response = try await api.searchPosts(
                query: query,
                page: page,
                limit: pageSize,
                communityId: communityId,
                creatorId: creatorId,
                filter: listing,
                sort: searchSortType
            )
        case let .v3(postSortType):
            response = try await api.searchPosts(
                query: query,
                page: page,
                limit: pageSize,
                communityId: communityId,
                creatorId: creatorId,
                filter: listing,
                sort: postSortType
            )
        }
        return .init(items: response, prevCursor: nil, nextCursor: nil)
    }
}

public class SearchPostFeedLoader: CorePostFeedLoader {
    // force unwrap because this should ALWAYS be a SearchPostFetcher
    public var searchPostFetcher: SearchPostFetcher { fetcher as! SearchPostFetcher }
    
    public init(
        api: ApiClient,
        query: String = "",
        pageSize: Int = 20,
        sortType: SearchPostFetcher.SortType,
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
        loadingState = .idle
    }
}
