//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-25.
//

import Foundation

public extension Message1Snapshot {
    init(from message: PieFedPrivateMessage) throws(ApiClientError) {
        self.actorId = message.apId
        self.id = message.id
        self.creatorId = message.creatorId
        self.recipientId = message.recipientId
        self.created = message.published
        
        self.content = message.content
        self.updated = message.updated
        self.read = message.read
        self.deleted = message.deleted
    }
}
