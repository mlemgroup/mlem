//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-05-10.
//

import Foundation

public struct Message2Snapshot: CacheIdentifiable {
    // Won't change, but the corresponding models need to
    // be updated within the `update` method of Message2.
    public let message: Message1Snapshot
    public let creator: Person1Snapshot
    public let recipient: Person1Snapshot
    
    public var cacheId: Int { message.cacheId }
    
    public init(
        message: Message1Snapshot,
        creator: Person1Snapshot,
        recipient: Person1Snapshot
    ) {
        self.message = message
        self.creator = creator
        self.recipient = recipient
    }
}
