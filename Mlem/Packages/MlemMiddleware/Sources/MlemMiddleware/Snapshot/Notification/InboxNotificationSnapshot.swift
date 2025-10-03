//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-05-06.
//

import Foundation

public struct InboxNotificationSnapshot: CacheIdentifiable {
    public let id: Int
    public var read: Bool

    public var cacheId: Int { id }

    public init(id: Int, read: Bool) {
        self.id = id
        self.read = read
    }
}

public enum InboxNotificationContentSnapshot {
    case reply(Comment2Snapshot)
    case mention(Comment2Snapshot)
    case message(Message2Snapshot)
}
