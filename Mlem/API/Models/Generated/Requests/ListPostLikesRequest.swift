//
//  ListPostLikesRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-20
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct ListPostLikesRequest: APIGetRequest {
    typealias Response = APIListPostLikesResponse

    let path = "/post/like/list"
    let queryItems: [URLQueryItem]

    init(
        postId: Int,
        page: Int?,
        limit: Int?
    ) {
        self.queryItems = [
            .init(name: "post_id", value: "\(postId)"),
            .init(name: "page", value: "\(page)"),
            .init(name: "limit", value: "\(limit)")
        ]
    }
}
