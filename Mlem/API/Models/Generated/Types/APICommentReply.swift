//
//  APICommentReply.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-20
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// CommentReply.ts
struct APICommentReply: Codable {
    let id: Int
    let recipientId: Int
    let commentId: Int
    let read: Bool
    let published: Date
}
