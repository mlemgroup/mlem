//
//  MessageCaches.swift
//
//
//  Created by Sjmarf on 05/07/2024.
//

import Foundation

class Message1Cache: CoreCache<Message1> {
    @MainActor
    func getModel(
        api: ApiClient,
        from snapshot: Message1Snapshot,
        myPersonId: Int,
        semaphore: UInt? = nil
    ) -> Message1 {
        if let item = retrieveModel(cacheId: snapshot.cacheId) {
            item.update(with: snapshot, semaphore: semaphore)
            return item
        }
        
        let newItem: Message1 = .init(
            api: api,
            actorId: snapshot.actorId,
            id: snapshot.id,
            creatorId: snapshot.creatorId,
            recipientId: snapshot.recipientId,
            isOwnMessage: myPersonId == snapshot.creatorId,
            content: snapshot.content,
            deleted: snapshot.deleted,
            created: snapshot.created,
            updated: snapshot.updated,
            read: snapshot.read
        )
        itemCache.put(newItem)
        return newItem
    }
    
    @MainActor
    func getModels(
        api: ApiClient,
        from snapshots: [Message1Snapshot],
        myPersonId: Int,
        semaphore: UInt? = nil
    ) -> [Message1] {
        snapshots.map { getModel(api: api, from: $0, myPersonId: myPersonId, semaphore: semaphore) }
    }
}

class Message2Cache: CoreCache<Message2> {
    @MainActor
    func getModel(
        api: ApiClient,
        from snapshot: Message2Snapshot,
        myPersonId: Int,
        semaphore: UInt? = nil
    ) -> Message2 {
        if let item = retrieveModel(cacheId: snapshot.cacheId) {
            item.update(with: snapshot, semaphore: semaphore)
            return item
        }
        
        let newItem: Message2 = .init(
            api: api,
            message1: api.caches.message1.getModel(api: api, from: snapshot.message, myPersonId: myPersonId),
            creator: api.caches.person1.getModel(api: api, from: snapshot.creator),
            recipient: api.caches.person1.getModel(api: api, from: snapshot.recipient)
        )
        itemCache.put(newItem)
        return newItem
    }
    
    @MainActor
    func getModels(
        api: ApiClient,
        from snapshots: [Message2Snapshot],
        myPersonId: Int,
        semaphore: UInt? = nil
    ) -> [Message2] {
        snapshots.map { getModel(api: api, from: $0, myPersonId: myPersonId, semaphore: semaphore) }
    }
}
