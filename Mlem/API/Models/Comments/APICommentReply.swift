//
//  APICommentReply.swift
//  Mlem
//
//  Created by Jonathan de Jong on 14.06.2023.
//

import Foundation

// lemmy_db_schema::source::comment_reply::CommentReply
struct APICommentReply: Decodable {
    let id: Int
    let recipientId: Int
    let commentId: Int
    let read: Bool
    let published: Date
    
    init(
        from commentReply: APICommentReply,
        id: Int? = nil,
        recipientId: Int? = nil,
        commentId: Int? = nil,
        read: Bool? = nil,
        published: Date? = nil
    ) {
        self.id = id ?? commentReply.id
        self.recipientId = recipientId ?? commentReply.recipientId
        self.commentId = commentId ?? commentReply.commentId
        self.read = read ?? commentReply.read
        self.published = published ?? commentReply.published
    }
}
