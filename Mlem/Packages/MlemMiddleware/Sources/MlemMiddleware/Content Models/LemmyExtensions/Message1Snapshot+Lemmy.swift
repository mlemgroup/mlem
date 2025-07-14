//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-07-14.
//

import Foundation

extension Message1Snapshot {
    init(from message: LemmyPrivateMessage) throws(ApiClientError) {
        self.actorId = message.apId
        self.id = message.id
        self.creatorId = message.creatorId
        self.recipientId = message.recipientId
        
        if let published = message.publishedAt ?? message.published {
            self.created = published
        } else {
            throw .responseMissingRequiredData("LemmyPrivateMessage published")
        }

        self.content = message.content
        self.updated = message.updatedAt ?? message.updated
        self.read = message.read
        self.deleted = message.deleted
    }
}
