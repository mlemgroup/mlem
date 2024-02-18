//
//  CreatePostLike.swift
//  Mlem
//
//  Created by Nicholas Lawson on 07/06/2023.
//

import Foundation

struct CreatePostLikeRequest: APIPostRequest {
    typealias Response = PostResponse

    let path = "post/like"
    let body: Body

    // lemmy_api_common::post::CreatePostLike
    struct Body: Encodable {
        let post_id: Int
        let score: Int
    }

    init(
        postId: Int,
        score: ScoringOperation
    ) {
        self.body = .init(post_id: postId, score: score.rawValue)
    }
}
