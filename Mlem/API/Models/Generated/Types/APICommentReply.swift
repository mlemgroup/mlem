//
//  APICommentReply.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// sources/js/types/CommentReply.ts
struct APICommentReply: Codable {
    let id: Int
    let recipient_id: Int
    let comment_id: Int
    let read: Bool
    let published: Date
}
