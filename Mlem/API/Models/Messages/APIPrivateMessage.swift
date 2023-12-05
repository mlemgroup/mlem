//
//  APIPrivateMessage.swift
//  Mlem
//
//  Created by Jake Shirley on 6/25/23.
//

import Foundation

// lemmy_db_schema::source::private_message::PrivateMessage
struct APIPrivateMessage: Decodable {
    let id: Int
    let content: String
    let creatorId: Int
    let recipientId: Int
    let local: Bool
    let read: Bool
    let updated: Date?
    let published: Date
    let deleted: Bool
    
    init(
        from apiPrivateMessage: APIPrivateMessage,
        read: Bool? = nil
    ) {
        self.id = apiPrivateMessage.id
        self.content = apiPrivateMessage.content
        self.creatorId = apiPrivateMessage.creatorId
        self.recipientId = apiPrivateMessage.recipientId
        self.local = apiPrivateMessage.local
        self.read = read ?? apiPrivateMessage.read
        self.updated = apiPrivateMessage.updated
        self.published = apiPrivateMessage.published
        self.deleted = apiPrivateMessage.deleted
    }
}
