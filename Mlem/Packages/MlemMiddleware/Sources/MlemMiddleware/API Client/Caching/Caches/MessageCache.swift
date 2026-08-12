//
//  MessageCache.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2026-06-15.
//

public enum AnyMessageSnapshot: CacheIdentifiable {
    case message1(Message1Snapshot)
    case message2(Message2Snapshot)
    
    public var cacheId: Int {
        switch self {
        case let .message1(snapshot): snapshot.cacheId
        case let .message2(snapshot): snapshot.cacheId
        }
    }
    
    public var creatorId: Int {
        switch self {
        case let .message1(snapshot): snapshot.creatorId
        case let .message2(snapshot): snapshot.message.creatorId
        }
    }
}

class MessageCache: CoreCache<Message> {
    @MainActor
    func getModel(
        api: ApiClient,
        from snapshot: AnyMessageSnapshot,
        myPersonId: Int,
        isStale: Bool = false
    ) -> Message {
        if let item = retrieveModel(cacheId: snapshot.cacheId) {
            if !isStale {
                updateModel(item, with: snapshot, myPersonId: myPersonId)
            }
            return item
        }
  
        let newItem = performModelTranslation(api: api, from: snapshot, myPersonId: myPersonId)
        itemCache.put(newItem)
        return newItem
    }
    
    @MainActor
    func getModels(
        api: ApiClient,
        from snapshots: [AnyMessageSnapshot],
        myPersonId: Int,
        isStale: Bool = false
    ) -> [Message] {
        snapshots.map { getModel(api: api, from: $0, myPersonId: myPersonId, isStale: isStale) }
    }
    
    @MainActor
    func performModelTranslation(api: ApiClient, from apiType: AnyMessageSnapshot, myPersonId: Int) -> Message {
        return .init(api: api, properties: .init(api: api, snapshot: apiType, isOwnMessage: myPersonId == apiType.creatorId))
    }
    
    @MainActor
    func updateModel(_ item: Message, with apiType: AnyMessageSnapshot, myPersonId: Int) {
        // attempt a direct update through the queue to avoid overwriting more recent data, and also
        // synchronously perform softUpdate to ensure high-tier data is available where expected
        let properties: MessageProperties = .init(api: item.api, snapshot: apiType, isOwnMessage: myPersonId == apiType.creatorId)
        Task {
            await item.updateQueue.attemptDirectUpdate(with: properties)
        }
        item.softUpdate(with: properties)
    }
}
