//
//  GetPostRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

struct GetPostRequest: APIGetRequest {
    typealias Response = APIGetPostResponse

    let path = "/post"
    let queryItems: [URLQueryItem]

    init(
        id: Int?,
        commentId: Int?
    ) {
        var request: APIGetPost = .init(
            id: id,
            comment_id: commentId
        )
        self.queryItems = request.toQueryItems()
    }
}
