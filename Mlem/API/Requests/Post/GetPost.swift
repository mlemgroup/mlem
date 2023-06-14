//
//  GetPosts.swift
//  Mlem
//
//  Created by Nicholas Lawson on 07/06/2023.
//

import Foundation

// lemmy_api_common::post::GetPost
struct GetPostRequest: APIGetRequest {

    typealias Response = GetPostResponse

    let instanceURL: URL
    let path = "post"
    let queryItems: [URLQueryItem]

    init(
        account: SavedAccount,
        id: Int?,
        commentId: Int?
    ) {
        self.instanceURL = account.instanceLink

        self.queryItems = [
            .init(name: "auth", value: account.accessToken),
            .init(name: "id", value: id?.description),
            .init(name: "comment_id", value: commentId?.description)
        ]
    }

    init(
        instanceURL: URL,
        id: Int?,
        commentId: Int?
    ) {
        self.instanceURL = instanceURL

        var queryItems: [URLQueryItem] = [
            .init(name: "id", value: id?.description),
            .init(name: "comment_id", value: commentId?.description)
        ]

        self.queryItems = queryItems
    }
}

// lemmy_api_common::post::GetPostResponse
struct GetPostResponse: Decodable {
    let posts: [APIPostView]
}
