//
//  GetPostsRequest.swift
//  Mlem
//
//  Created by Nicholas Lawson on 07/06/2023.
//

import Foundation

struct GetPostsRequest: APIGetRequest {
    
    typealias Response = GetPostsResponse
    
    let instanceURL: URL
    let path = "post/list"
    let queryItems: [URLQueryItem]
    
    init(
        account: SavedAccount,
        communityId: Int?,
        page: Int,
        sort: SortingOptions?,
        type: FeedType = .all
    ) {
        self.instanceURL = account.instanceLink

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
    }
}

struct GetPostsResponse: Decodable {
    let posts: [APIPostView]
}
