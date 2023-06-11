//
//  GetCommentsRequest.swift
//  Mlem
//
//  Created by Nicholas Lawson on 08/06/2023.
//

import Foundation

struct GetCommentsRequest: APIGetRequest {
    
    typealias Response = GetCommentsResponse
    
    let instanceURL: URL
    let path = "comment/list"
    let queryItems: [URLQueryItem]
    
    init(
        account: SavedAccount,
        postId: Int,
        maxDepth: Int = 15,
        type: FeedType = .all
    ) {
        self.instanceURL = account.instanceLink
        self.queryItems = [
            .init(name: "auth", value: account.accessToken),
            .init(name: "post_id", value: "\(postId)"),
            .init(name: "max_depth", value: "\(maxDepth)"),
            .init(name: "type_", value: type.rawValue)
        ]
    }
}

struct GetCommentsResponse: Decodable {
    let comments: [APICommentView]
}
