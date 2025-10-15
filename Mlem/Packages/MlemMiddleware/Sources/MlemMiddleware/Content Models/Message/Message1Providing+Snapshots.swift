//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-10-12.
//

import Foundation

extension Message1Providing {
    func takeSnapshot1() -> Message1Snapshot {
        .init(
            actorId: actorId,
            id: id,
            creatorId: creatorId,
            recipientId: recipientId,
            created: created,
            content: content,
            updated: updated,
            read: read,
            deleted: deleted
        )
    }
}
