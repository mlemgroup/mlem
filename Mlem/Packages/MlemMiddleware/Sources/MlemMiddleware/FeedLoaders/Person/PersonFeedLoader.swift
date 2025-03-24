//
//  PersonFeedLoader.swift
//
//
//  Created by Sjmarf on 08/09/2024.
//

import Foundation

@Observable
class PersonFetcher: Fetcher<Person2> {
    var query: String
    /// `listing` can be set to `.local` from 0.19.4 onwards.
    var listing: ApiListingType
    var sort: SearchSortType
    
    init(api: ApiClient, pageSize: Int, query: String, listing: ApiListingType, sort: SearchSortType) {
        self.query = query
        self.listing = listing
        self.sort = sort
        
        super.init(api: api, pageSize: pageSize)
    }
    
    override func fetchPage(_ page: Int) async throws -> FetchResponse {
        let communities = try await api.searchPeople(
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
public class PersonFeedLoader: StandardFeedLoader<Person2> {
    public var api: ApiClient
    
    // force unwrap because this should ALWAYS be a PersonFetcher
    var personFetcher: PersonFetcher { fetcher as! PersonFetcher }
    
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
            fetcher: PersonFetcher(api: api, pageSize: pageSize, query: query, listing: listing, sort: sort)
        )
    }
    
    public func refresh(
        query: String? = nil,
        listing: ApiListingType? = nil,
        sort: SearchSortType? = nil,
        clearBeforeRefresh: Bool = false
    ) async throws {
        personFetcher.query = query ?? personFetcher.query
        personFetcher.listing = listing ?? personFetcher.listing
        personFetcher.sort = sort ?? personFetcher.sort
        try await super.refresh(clearBeforeRefresh: clearBeforeRefresh)
    }
}
