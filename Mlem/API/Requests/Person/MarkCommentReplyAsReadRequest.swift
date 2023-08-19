//
//  MarkCommentReplyAsRead.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-01.
//

import Foundation

struct MarkCommentReplyAsRead: APIPostRequest {
    
    typealias Response = CommentReplyResponse
    
    let instanceURL: URL
    let path = "comment/mark_as_read"
    let body: Body
    
    struct Body: Encodable {
        let comment_reply_id: Int
        let read: Bool
        let auth: String
    }
    
    init(
        session: APISession,
        commentId: Int,
        read: Bool
    ) {
        self.instanceURL = session.URL
        self.body = .init(
            comment_reply_id: commentId,
            read: read,
            auth: session.token
        )
    }
}

struct CommentReplyResponse: Decodable {
    let commentReplyView: APICommentReplyView
}
