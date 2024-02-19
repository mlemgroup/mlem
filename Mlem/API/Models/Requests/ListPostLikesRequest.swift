//
//  ListPostLikesRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

struct ListPostLikesRequest: APIGetRequest {
    typealias Response = APIListPostLikesResponse

    let path = "/post/like/list"
    let queryItems: [URLQueryItem]

    init(
        postId: Int,
        page: Int,
        limit: Int
    ) {
        var request: APIListPostLikes = .init(
            post_id: postId,
            page: page,
            limit: limit
        )
        self.queryItems = request.toQueryItems()
    }
}
