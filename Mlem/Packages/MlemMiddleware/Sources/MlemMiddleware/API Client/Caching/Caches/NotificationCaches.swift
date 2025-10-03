//
//  NotificationCaches.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-01.
//

import Foundation

class NotificationCache: ApiTypeBackedCache<InboxNotification, InboxNotificationSnapshot> {
    override func performModelTranslation(api: ApiClient, from snapshot: InboxNotificationSnapshot) -> InboxNotification {
        .init(
            api: api,
            id: snapshot.id,
            read: snapshot.read
        )
    }
    
    override func updateModel(_ item: InboxNotification, with snapshot: InboxNotificationSnapshot, semaphore: UInt? = nil) {
        // TODO: UpdateQueue move updateModel responsibilities fully out of the cache
    }
}
