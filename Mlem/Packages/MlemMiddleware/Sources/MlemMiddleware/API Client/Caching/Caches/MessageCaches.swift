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
        from apiType: ApiPrivateMessage,
        myPersonId: Int,
        semaphore: UInt? = nil
    ) -> Message1 {
        if let item = retrieveModel(cacheId: apiType.cacheId) {
            item.update(with: apiType, semaphore: semaphore)
            return item
        }
        
        let newItem: Message1 = .init(
            api: api,
            actorId: apiType.actorId,
            id: apiType.id,
            creatorId: apiType.creatorId,
            recipientId: apiType.recipientId,
            isOwnMessage: myPersonId == apiType.creatorId,
            content: apiType.content,
            deleted: apiType.deleted,
            created: apiType.published,
            updated: apiType.updated,
            read: apiType.read
        )
        itemCache.put(newItem)
        return newItem
    }
    
    @MainActor
    func getModels(
        api: ApiClient,
        from apiTypes: [ApiPrivateMessage],
        myPersonId: Int,
        semaphore: UInt? = nil
    ) -> [Message1] {
        apiTypes.map { getModel(api: api, from: $0, myPersonId: myPersonId, semaphore: semaphore) }
    }
}

class Message2Cache: CoreCache<Message2> {
    @MainActor
    func getModel(
        api: ApiClient,
        from apiType: ApiPrivateMessageView,
        myPersonId: Int,
        semaphore: UInt? = nil
    ) -> Message2 {
        if let item = retrieveModel(cacheId: apiType.cacheId) {
            item.update(with: apiType, semaphore: semaphore)
            return item
        }
        
        let newItem: Message2 = .init(
            api: api,
            message1: api.caches.message1.getModel(api: api, from: apiType.privateMessage, myPersonId: myPersonId),
            creator: api.caches.person1.getModel(api: api, from: apiType.creator),
            recipient: api.caches.person1.getModel(api: api, from: apiType.recipient)
        )
        itemCache.put(newItem)
        return newItem
    }
    
    @MainActor
    func getModels(
        api: ApiClient,
        from apiTypes: [ApiPrivateMessageView],
        myPersonId: Int,
        semaphore: UInt? = nil
    ) -> [Message2] {
        apiTypes.map { getModel(api: api, from: $0, myPersonId: myPersonId, semaphore: semaphore) }
    }
}
