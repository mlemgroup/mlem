//
//  GetCommentsRequest.swift
//  Mlem
//
//  Created by Nicholas Lawson on 08/06/2023.
//

import Foundation

struct GetCommentsRequest: APIRequest {
    
    typealias Response = GetCommentsResponse
    
    let endpoint: URL
    let method: HTTPMethod
    let queryItems: [URLQueryItem]
    
    init(
        account: SavedAccount,
        postId: Int,
        maxDepth: Int = 15,
        type: FeedType = .all
    ) {
        let queryItems: [URLQueryItem] = [
            .init(name: "auth", value: account.accessToken),
            .init(name: "post_id", value: "\(postId)"),
            .init(name: "max_depth", value: "\(maxDepth)"),
            .init(name: "type_", value: type.rawValue)
        ]
        
        self.queryItems = queryItems
        self.endpoint = account.instanceLink
            .appending(path: "comment")
            .appending(path: "list")
            .appending(queryItems: queryItems)
        self.method = .get
    }
}

struct GetCommentsResponse: Decodable {
    let comments: [APICommentView]
}
