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
}
