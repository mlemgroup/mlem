//
//  ListCommentLikesRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct ListCommentLikesRequest: ApiGetRequest {
    typealias Response = ApiListCommentLikesResponse

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
