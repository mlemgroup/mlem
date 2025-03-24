//
//  SearchCommentFeedLoader.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-01-18.
//

import Foundation

@Observable
public class SearchCommentFetcher: Fetcher<Comment2> {
    public enum SortType {
        case v4(SearchSortType)
        case v3(CommentSortType)
    }
    
    public var query: String
    public var listing: ApiListingType
    public var sort: SortType
    public var communityId: Int?
    public var creatorId: Int?
    
    init(
        api: ApiClient,
        query: String,
        communityId: Int?,
        creatorId: Int?,
        pageSize: Int,
        listing: ApiListingType,
        sort: SortType
    ) {
        self.query = query
        self.communityId = communityId
        self.creatorId = creatorId
        self.listing = listing
        self.sort = sort
        
        super.init(api: api, pageSize: pageSize)
    }
    
    override func fetchPage(_ page: Int) async throws -> FetchResponse {
        let comments: [Comment2]
        switch sort {
        case let .v4(searchSortType):
            comments = try await api.searchComments(
                query: query,
                page: page,
                limit: pageSize,
                communityId: communityId,
                creatorId: creatorId,
                filter: listing,
                sort: searchSortType
            )
        case let .v3(commentSortType):
            comments = try await api.searchComments(
                query: query,
                page: page,
                limit: pageSize,
                communityId: communityId,
                creatorId: creatorId,
                filter: listing,
                sort: commentSortType
            )
        }
        
        return .init(
            items: comments,
            prevCursor: nil,
            nextCursor: nil
        )
    }
    
    public func changeApi(to newApi: ApiClient) async {
        await super.changeApi(to: newApi, context: .none())
    }
}

@Observable
public class SearchCommentFeedLoader: StandardFeedLoader<Comment2> {
    public var api: ApiClient
    
    // force unwrap because this should ALWAYS be a SearchCommentFetcher
    public var searchCommentFetcher: SearchCommentFetcher { fetcher as! SearchCommentFetcher }
    
    public init(
        api: ApiClient,
        query: String = "",
        communityId: Int? = nil,
        creatorId: Int? = nil,
        pageSize: Int = 20,
        listing: ApiListingType = .all,
        sort: SearchCommentFetcher.SortType = .v4(.top(.allTime))
    ) {
        self.api = api

        super.init(
            filter: .init(),
            fetcher: SearchCommentFetcher(
                api: api,
                query: query,
                communityId: communityId,
                creatorId: creatorId,
                pageSize: pageSize,
                listing: listing,
                sort: sort
            )
        )
    }
    
    public func refresh(
        query: String? = nil,
        listing: ApiListingType? = nil,
        sort: SearchCommentFetcher.SortType? = nil,
        clearBeforeRefresh: Bool = false
    ) async throws {
        searchCommentFetcher.query = query ?? searchCommentFetcher.query
        searchCommentFetcher.listing = listing ?? searchCommentFetcher.listing
        searchCommentFetcher.sort = sort ?? searchCommentFetcher.sort
        try await refresh(clearBeforeRefresh: clearBeforeRefresh)
    }
}
