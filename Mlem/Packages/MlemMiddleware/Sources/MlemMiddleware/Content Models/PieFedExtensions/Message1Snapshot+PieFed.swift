//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-25.
//

import Foundation

public extension Message1Snapshot {
    init(from message: PieFedPrivateMessage) throws(ApiClientError) {
        var deleted = message.deleted
        // This is required on PieFed 1.1. It *should* no longer be necessary
        // from PieFed 1.2 onwards. Check to be sure though
        if message.content == "Message Deleted" {
            deleted = true
        }

        self.init(
            actorId: message.apId,
            id: message.id,
            creatorId: message.creatorId,
            recipientId: message.recipientId,
            created: message.published,
            content: message.content,
            updated: nil,
            read: message.read,
            deleted: deleted
        )
    }
}
