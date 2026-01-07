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
