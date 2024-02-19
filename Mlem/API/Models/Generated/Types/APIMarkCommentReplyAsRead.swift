//
//  APIMarkCommentReplyAsRead.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// sources/js/types/MarkCommentReplyAsRead.ts
struct APIMarkCommentReplyAsRead: Codable {
    let comment_reply_id: Int
    let read: Bool
}
