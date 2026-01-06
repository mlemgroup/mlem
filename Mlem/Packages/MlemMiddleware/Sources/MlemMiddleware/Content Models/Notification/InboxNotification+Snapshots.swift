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
        if isResultOfTask, self.read != snapshot.read {
            let type: InboxItemType = switch content.type {
            case .mention: .mention
            case .reply: .reply
            case .message: .message
            }
            api.unreadCount?.verifyItem(itemType: type, isRead: snapshot.read)
        }
        setIfChanged(\.read, snapshot.read)
    }
    
    func takeSnapshot() -> InboxNotificationSnapshot {
        .init(
            id: id,
            contentId: contentId,
            read: read,
            content: content.takeSnapshot()
        )
    }
}
