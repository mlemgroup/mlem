//
//  GetPostsRequest.swift
//  Mlem
//
//  Created by Nicholas Lawson on 07/06/2023.
//

import Foundation

struct GetPostsRequest: APIRequest {
    
    typealias Response = GetPostsResponse
    
    let endpoint: URL
    let method: HTTPMethod
    let queryItems: [URLQueryItem]
    
    init(
        account: SavedAccount,
        communityId: Int?,
        page: Int,
        sort: SortingOptions?,
        type: FeedType = .all
    ) {
        var queryItems: [URLQueryItem] = [
            .init(name: "auth", value: account.accessToken),
            .init(name: "page", value: "\(page)"),
            .init(name: "type_", value: type.rawValue)
        ]
        
        if let sort {
            queryItems.append(
                .init(name: "sort", value: sort.rawValue)
            )
        }
        
        if let communityId {
            queryItems.append(
                .init(name: "community_id", value: "\(communityId)")
            )
        }
        
        self.queryItems = queryItems
        self.endpoint = account.instanceLink
            .appending(path: "post")
            .appending(path: "list")
            .appending(queryItems: queryItems)
        self.method = .get
    }
}

struct GetPostsResponse: Decodable {
    let posts: [APIPostView]
}
