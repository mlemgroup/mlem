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
}
