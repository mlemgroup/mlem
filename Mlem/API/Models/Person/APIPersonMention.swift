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
}

extension APIPersonMention: Equatable {
    static func == (lhs: APIPersonMention, rhs: APIPersonMention) -> Bool {
        lhs.id == rhs.id
    }
}
