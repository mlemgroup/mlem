//
//  APIPersonMention.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-26.
//

import Foundation

// lemmy_db_schema::source::person_mention::PersonMention
struct APIPersonMention: Decodable {
    let id: Int
    let recipientId: Int
    let commentId: Int
    let read: Bool
    let published: Date
    
    init(
        from personMention: APIPersonMention,
        id: Int? = nil,
        recipientId: Int? = nil,
        commentId: Int? = nil,
        read: Bool? = nil,
        published: Date? = nil
    ) {
        self.id = id ?? personMention.id
        self.recipientId = recipientId ?? personMention.recipientId
        self.commentId = commentId ?? personMention.commentId
        self.read = read ?? personMention.read
        self.published = published ?? personMention.published
    }
}

extension APIPersonMention: Equatable {
    static func == (lhs: APIPersonMention, rhs: APIPersonMention) -> Bool {
        lhs.id == rhs.id
    }
}
