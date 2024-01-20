//
//  GetPosts.swift
//  Mlem
//
//  Created by Nicholas Lawson on 07/06/2023.
//

import Foundation

// lemmy_api_common::post::GetPosts
struct GetPostsRequest: APIGetRequest {
    typealias Response = GetPostsResponse

    let instanceURL: URL
    let path = "post/list"
    let queryItems: [URLQueryItem]
    
    init(
        session: APISession,
        communityId: Int?,
        page: Int,
        cursor: String?,
        sort: PostSortType?,
        type: NewFeedType,
        limit: Int? = nil,
        savedOnly: Bool? = nil,
        communityName: String? = nil
        // TODO: 0.19 support add liked_only and disliked_only fields
    ) throws {
        self.instanceURL = try session.instanceUrl
        var queryItems: [URLQueryItem] = [
            .init(name: "type_", value: type.typeString),
            .init(name: "sort", value: sort.map(\.rawValue)),
            .init(name: "community_id", value: communityId.map(String.init)),
            .init(name: "community_name", value: communityName),
            .init(name: "limit", value: limit.map(String.init)),
            .init(name: "saved_only", value: savedOnly.map(String.init))
        ]
        
        let paginationParameter: URLQueryItem
        if let cursor {
            paginationParameter = .init(name: "page_cursor", value: cursor)
        } else {
            paginationParameter = .init(name: "page", value: "\(page)")
        }
        
        queryItems.append(paginationParameter)
        
        if let token = try? session.token {
            queryItems.append(
                .init(name: "auth", value: token)
            )
        }
        
        self.queryItems = queryItems
    }
}

// TODO: ERIC delete this
// lemmy_api_common::post::GetPosts
struct OldGetPostsRequest: APIGetRequest {
    typealias Response = GetPostsResponse

    let instanceURL: URL
    let path = "post/list"
    let queryItems: [URLQueryItem]
    
    init(
        session: APISession,
        communityId: Int?,
        page: Int,
        cursor: String?,
        sort: PostSortType?,
        type: FeedType,
        limit: Int? = nil,
        savedOnly: Bool? = nil,
        communityName: String? = nil
        // TODO: 0.19 support add liked_only and disliked_only fields
    ) throws {
        self.instanceURL = try session.instanceUrl
        var queryItems: [URLQueryItem] = [
            .init(name: "type_", value: type.rawValue),
            .init(name: "sort", value: sort.map(\.rawValue)),
            .init(name: "community_id", value: communityId.map(String.init)),
            .init(name: "community_name", value: communityName),
            .init(name: "limit", value: limit.map(String.init)),
            .init(name: "saved_only", value: savedOnly.map(String.init))
        ]
        
        let paginationParameter: URLQueryItem
        if let cursor {
            paginationParameter = .init(name: "page_cursor", value: cursor)
        } else {
            paginationParameter = .init(name: "page", value: "\(page)")
        }
        
        queryItems.append(paginationParameter)
        
        if let token = try? session.token {
            queryItems.append(
                .init(name: "auth", value: token)
            )
        }
        
        self.queryItems = queryItems
    }
}

// lemmy_api_common::post::GetPostsResponse
struct GetPostsResponse: Decodable {
    let posts: [APIPostView]
    let nextPage: String?
}
