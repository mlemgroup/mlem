//
//  ListCommentLikesRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

struct ListCommentLikesRequest: APIGetRequest {
    typealias Response = APIListCommentLikesResponse

    let path = "/comment/like/list"
    let queryItems: [URLQueryItem]

    init(
        commentId: Int,
        page: Int,
        limit: Int
    ) {
        var request: APIListCommentLikes = .init(
            comment_id: commentId,
            page: page,
            limit: limit
        )
        self.queryItems = request.toQueryItems()
    }
}
