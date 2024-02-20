//
//  DeleteCommentRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-20
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct DeleteCommentRequest: APIPostRequest {
    typealias Body = APIDeleteComment
    typealias Response = APICommentResponse

    let path = "/comment/delete"
    let body: Body?

    init(
        commentId: Int,
        deleted: Bool
    ) {
        self.body = .init(
            commentId: commentId,
            deleted: deleted
        )
    }
}
