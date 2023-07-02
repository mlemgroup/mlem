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
        account: SavedAccount,
        commentId: Int,
        read: Bool
    ) {
        self.instanceURL = account.instanceLink
        self.body = .init(
            comment_reply_id: commentId,
            read: read,
            auth: account.accessToken
        )
    }
}

struct CommentReplyResponse: Decodable {
    let commentReplyView: APICommentReplyView
}

// pub struct MarkCommentReplyAsRead {
//   pub comment_reply_id: CommentReplyId,
//   pub read: bool,
//   pub auth: Sensitive<String>,
// }
