//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-07-14.
//

import Foundation

extension Message1Snapshot {
    init(from message: LemmyPrivateMessage) throws(ApiClientError) {
        guard let published = message.publishedAt ?? message.published else {
            throw .responseMissingRequiredData("LemmyPrivateMessage published")
        }

        self.init(
            actorId: message.apId,
            id: message.id,
            creatorId: message.creatorId,
            recipientId: message.recipientId,
            created: published,
            content: message.content,
            updated: message.updatedAt ?? message.updated,
            read: message.read ?? false, // Temporary: Fix in 1.0
            deleted: message.deleted
        )
    }
}
