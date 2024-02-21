//
//  ListPostLikesRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct ListPostLikesRequest: ApiGetRequest {
    typealias Response = ApiListPostLikesResponse

    let path = "/post/like/list"
    let queryItems: [URLQueryItem]

    init(
        postId: Int,
        page: Int?,
        limit: Int?
    ) {
        self.queryItems = [
            .init(name: "post_id", value: String(postId)),
            .init(name: "page", value: page.map(String.init)),
            .init(name: "limit", value: limit.map(String.init))
        ]
    }
}
