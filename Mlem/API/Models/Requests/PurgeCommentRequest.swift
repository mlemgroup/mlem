//
//  PurgeCommentRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

struct PurgeCommentRequest: APIPostRequest {
    typealias Body = APIPurgeComment
    typealias Response = APISuccessResponse

    let path = "/admin/purge/comment"
    let body: Body?

    init(
        commentId: Int,
        reason: String
    ) {
        self.body = .init(
            comment_id: commentId,
            reason: reason
        )
    }
}
