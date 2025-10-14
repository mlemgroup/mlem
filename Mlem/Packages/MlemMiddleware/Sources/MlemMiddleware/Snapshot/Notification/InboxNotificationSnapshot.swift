//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-05-06.
//

import Foundation

public struct InboxNotificationSnapshot: CacheIdentifiable {
    public let id: Int
    public let contentId: Int
    public var read: Bool
    public var content: InboxNotificationContentSnapshot

    public var cacheId: Int { id }

    public init(
        id: Int,
        contentId: Int,
        read: Bool,
        content: InboxNotificationContentSnapshot
    ) {
        self.id = id
        self.contentId = contentId
        self.read = read
        self.content = content
    }
}

public enum InboxNotificationContentSnapshot {
    case reply(Comment2Snapshot)
    case mention(Comment2Snapshot)
    case message(Message2Snapshot)
}
