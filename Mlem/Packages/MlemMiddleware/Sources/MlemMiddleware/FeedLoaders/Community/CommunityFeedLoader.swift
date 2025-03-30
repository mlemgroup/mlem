//
//  CommunityFeedLoader.swift
//
//
//  Created by Sjmarf on 08/09/2024.
//

import Foundation

@Observable
class CommunityFetcher: Fetcher<Community2> {
    var query: String
    var listing: ApiListingType
    var sort: SearchSortType
    
    init(api: ApiClient, query: String, pageSize: Int, listing: ApiListingType, sort: SearchSortType) {
        self.query = query
        self.listing = listing
        self.sort = sort
        
        super.init(api: api, pageSize: pageSize)
    }
    
    override func fetchPage(_ page: Int) async throws -> FetchResponse {
        let communities = try await api.searchCommunities(
            query: query,
            page: page,
            limit: pageSize,
            filter: listing,
            sort: sort
        )
        
        return .init(
            items: communities,
            prevCursor: nil,
            nextCursor: nil
        )
    }
}

@Observable
public class CommunityFeedLoader: StandardFeedLoader<Community2> {
    public var api: ApiClient
    
    // force unwrap because this should ALWAYS be a CommunityFetcher
    var communityFetcher: CommunityFetcher { fetcher as! CommunityFetcher }
    
    public init(
        api: ApiClient,
        query: String = "",
        pageSize: Int = 20,
        listing: ApiListingType = .all,
        sort: SearchSortType = .top(.allTime)
    ) {
        self.api = api

        super.init(
            filter: .init(),
            fetcher: CommunityFetcher(
                api: api,
                query: query,
                pageSize: pageSize,
                listing: listing,
                sort: sort
            )
        )
    }
    
    public func refresh(
        query: String? = nil,
        listing: ApiListingType? = nil,
        sort: SearchSortType? = nil,
        clearBeforeRefresh: Bool = false
    ) async throws {
        communityFetcher.query = query ?? communityFetcher.query
        communityFetcher.listing = listing ?? communityFetcher.listing
        communityFetcher.sort = sort ?? communityFetcher.sort
        try await refresh(clearBeforeRefresh: clearBeforeRefresh)
    }
}
