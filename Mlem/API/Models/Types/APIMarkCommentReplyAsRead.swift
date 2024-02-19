//
//  APIMarkCommentReplyAsRead.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/MarkCommentReplyAsRead.ts
struct APIMarkCommentReplyAsRead: Codable {
    let comment_reply_id: Int
    let read: Bool

    func toQueryItems() -> [URLQueryItem] {
        [
            .init(name: "comment_reply_id", value: String(comment_reply_id)),
            .init(name: "read", value: String(read))
        ]
    }
}
