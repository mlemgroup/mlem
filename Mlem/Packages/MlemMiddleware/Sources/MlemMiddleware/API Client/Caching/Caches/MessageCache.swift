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
