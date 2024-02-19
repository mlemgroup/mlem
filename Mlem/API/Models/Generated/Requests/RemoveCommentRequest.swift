//
//  RemoveCommentRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct RemoveCommentRequest: APIPostRequest {
    typealias Body = APIRemoveComment
    typealias Response = APICommentResponse

    let path = "/comment/remove"
    let body: Body?

    init(
        commentId: Int,
        removed: Bool,
        reason: String?
    ) {
        self.body = .init(
            comment_id: commentId,
            removed: removed,
            reason: reason
        )
    }
}
