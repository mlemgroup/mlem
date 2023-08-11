//
//  DeleteComment.swift
//  Mlem
//
//  Created by Nicholas Lawson on 08/06/2023.
//

import Foundation

struct DeleteCommentRequest: APIPostRequest {

    typealias Response = CommentResponse

    let instanceURL: URL
    let path = "comment/delete"
    let body: Body

    // lemmy_api_common::comment::DeleteComment
    struct Body: Encodable {
        let comment_id: Int
        let deleted: Bool
        let auth: String
    }

    init(
        session: APISession,
        commentId: Int,
        deleted: Bool
    ) {
        self.instanceURL = session.URL
        self.body = .init(
            comment_id: commentId,
            deleted: deleted,
            auth: session.token
        )
    }
}
