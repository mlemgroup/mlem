//
//  SearchRequest.swift
//  Mlem
//
//  Created by Nicholas Lawson on 07/06/2023.
//

import Foundation

enum SearchType: String, Codable {
    case all = "All"
    case comments = "Comments"
    case communities = "Communities"
    case posts = "Posts"
    case url = "Url"
    case users = "Users"
}

struct SearchRequest: APIGetRequest {
    
    typealias Response = SearchResponse
    
    let instanceURL: URL
    let path = "search"
    let queryItems: [URLQueryItem]
    
    init(
        account: SavedAccount,
        query: String,
        searchType: SearchType,
        sortOption: SortingOptions = .topAll,
        listingType: FeedType = .all
    ) {
        self.instanceURL = account.instanceLink
        self.queryItems = [
            .init(name: "auth", value: account.accessToken),
            .init(name: "type_", value: searchType.rawValue),
            .init(name: "sort", value: sortOption.rawValue),
            .init(name: "listing_type", value: listingType.rawValue),
            .init(name: "q", value: query)
        ]
    }
}

struct SearchResponse: Decodable {
    let comments: [APICommentView]
    let communities: [APICommunityView]
    let posts: [APIPostView]
    let type_: SearchType
    let users: [APIPersonView]
}
