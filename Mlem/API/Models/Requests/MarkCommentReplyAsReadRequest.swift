//
//  MarkCommentReplyAsReadRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

struct MarkCommentReplyAsReadRequest: APIPostRequest {
    typealias Body = APIMarkCommentReplyAsRead
    typealias Response = APICommentReplyResponse

    let path = "/comment/mark_as_read"
    let body: Body?

    init(
        commentReplyId: Int,
        read: Bool
    ) {
        self.body = .init(
            comment_reply_id: commentReplyId,
            read: read
        )
    }
}
