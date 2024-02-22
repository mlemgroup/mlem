//
//  GetPosts.swift
//  Mlem
//
//  Created by Nicholas Lawson on 07/06/2023.
//

import Foundation

// lemmy_api_common::post::GetPosts
struct GetPostsRequest: ApiGetRequest {
    typealias Response = ApiGetPostsResponse

    let path = "post/list"
    let queryItems: [URLQueryItem]
    
    init(
        communityId: Int?,
        page: Int,
        cursor: String?,
        sort: ApiSortType?,
        type: ApiListingType,
        limit: Int? = nil,
        savedOnly: Bool? = nil,
        communityName: String? = nil
        // TODO: 0.19 support add liked_only and disliked_only fields
    ) throws {
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
        
        self.queryItems = queryItems
    }
}
