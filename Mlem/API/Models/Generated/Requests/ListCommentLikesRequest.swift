//
//  ListCommentLikesRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct ListCommentLikesRequest: APIGetRequest {
    typealias Response = APIListCommentLikesResponse

    let path = "/comment/like/list"
    let queryItems: [URLQueryItem]

    init(
        commentId: Int,
        page: Int?,
        limit: Int?
    ) {
        self.queryItems = [
            .init(name: "comment_id", value: "\(commentId)"),
            .init(name: "page", value: "\(page)"),
            .init(name: "limit", value: "\(limit)")
        ]
    }
}
