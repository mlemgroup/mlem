//
//  CreatePostLike.swift
//  Mlem
//
//  Created by Nicholas Lawson on 07/06/2023.
//

import Foundation

struct CreatePostLikeRequest: APIPostRequest {

    typealias Response = PostResponse

    let instanceURL: URL
    let path = "post/like"
    let body: Body

    // lemmy_api_common::post::CreatePostLike
    struct Body: Encodable {
        let auth: String
        let post_id: Int
        let score: Int
    }

    init(
        account: SavedAccount,
        postId: Int,
        score: ScoringOperation
    ) {
        self.instanceURL = account.instanceLink
        self.body = .init(auth: account.accessToken, post_id: postId, score: score.rawValue)
    }
}
