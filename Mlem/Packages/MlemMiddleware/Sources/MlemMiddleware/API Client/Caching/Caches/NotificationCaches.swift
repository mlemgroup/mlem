//
//  NotificationCaches.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-01.
//

import Foundation

class NotificationCache: CoreCache<InboxNotification> {
    @MainActor
    func getModel(
        api: ApiClient,
        from snapshot: InboxNotificationSnapshot,
        myPersonId: Int,
        semaphore: UInt? = nil
    ) -> InboxNotification {
        if let item = retrieveModel(cacheId: snapshot.cacheId) {
            Task {
                await item.updateQueue.attemptDirectUpdate(with: snapshot)
            }
            return item
        }

        let content: InboxNotificationContent = switch snapshot.content {
        case let .reply(commentSnapshot):
            .reply(api.caches.comment2.getModel(api: api, from: commentSnapshot))
        case let .mention(commentSnapshot):
            .mention(api.caches.comment2.getModel(api: api, from: commentSnapshot))
        case let .message(messageSnapshot):
            .message(api.caches.message2.getModel(api: api, from: messageSnapshot, myPersonId: myPersonId))
        }

        let newItem: InboxNotification = .init(
            api: api,
            id: snapshot.id,
            contentId: snapshot.contentId,
            read: snapshot.read,
            content: content
        )
        itemCache.put(newItem)
        return newItem
    }

    @MainActor
    func getModels(
        api: ApiClient,
        from snapshots: [InboxNotificationSnapshot],
        myPersonId: Int,
        semaphore: UInt? = nil
    ) -> [InboxNotification] {
        snapshots.map { getModel(api: api, from: $0, myPersonId: myPersonId, semaphore: semaphore) }
    }
}
