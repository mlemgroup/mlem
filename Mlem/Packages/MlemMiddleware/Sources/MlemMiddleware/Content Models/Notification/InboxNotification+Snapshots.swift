//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-10-12.
//

import Foundation

extension InboxNotification {
    @MainActor
    func snapshotUpdate(with snapshot: InboxNotificationSnapshot, isResultOfTask: Bool) {
        switch self.content {
        case let .message(message) where message.isOwnMessage:
            break
        default:
            setIfChanged(\.read, snapshot.read)
        }
    }
    
    func takeSnapshot() -> InboxNotificationSnapshot? {
        guard let snapshot = content.takeSnapshot() else { return nil }
        return .init(
            id: id,
            contentId: contentId,
            read: read,
            content: snapshot
        )
    }
}
