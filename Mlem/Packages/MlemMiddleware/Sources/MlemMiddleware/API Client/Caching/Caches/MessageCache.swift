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
}

class MessageCache: ApiTypeBackedCache<Message, AnyMessageSnapshot> {
    override func performModelTranslation(api: ApiClient, from apiType: AnyMessageSnapshot) -> Message {
        return .init(api: api, properties: .init(api: api, snapshot: apiType))
    }
    
    override func updateModel(_ item: Message, with apiType: AnyMessageSnapshot, semaphore: UInt? = nil) {
        // attempt a direct update through the queue to avoid overwriting more recent data, and also
        // synchronously perform softUpdate to ensure high-tier data is available where expected
        let properties: MessageProperties = .init(api: item.api, snapshot: apiType)
        Task {
            await item.updateQueue.attemptDirectUpdate(with: properties)
        }
        item.softUpdate(with: properties)
    }
}
