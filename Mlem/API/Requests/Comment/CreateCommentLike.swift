//
//  CreateCommentLike.swift
//  Mlem
//
//  Created by Nicholas Lawson on 09/06/2023.
//

import Foundation

struct CreateCommentLikeRequest: APIPostRequest {

    typealias Response = CommentResponse

    let instanceURL: URL
    let path = "comment/like"
    let body: Body

    // lemmy_api_common::comment::CreateCommentLike
    struct Body: Encodable {
        let comment_id: Int
        let score: Int
        let auth: String
    }

    init(
        session: APISession,
        commentId: Int,
        score: Int
    ) {
        self.instanceURL = session.URL
        self.body = .init(
            comment_id: commentId,
            score: score,
            auth: session.token
        )
    }
}
