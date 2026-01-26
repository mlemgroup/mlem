//
//  PostCache.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2026-01-03.
//

public enum AnyPostSnapshot: CacheIdentifiable {
    case post1(Post1Snapshot)
    case post2(Post2Snapshot)
    case post3(Post3Snapshot)
    
    public var cacheId: Int {
        switch self {
        case let .post1(snapshot): snapshot.cacheId
        case let .post2(snapshot): snapshot.cacheId
        case let .post3(snapshot): snapshot.cacheId
        }
    }
}

class PostCache: ApiTypeBackedCache<Post, AnyPostSnapshot> {
    override func performModelTranslation(api: ApiClient, from apiType: AnyPostSnapshot) -> Post {
        return .init(api: api, properties: .init(api: api, snapshot: apiType))
    }
    
    override func updateModel(_ item: Post, with apiType: AnyPostSnapshot, semaphore: UInt? = nil) {
        // attempt a direct update through the queue to avoid overwriting more recent data, and also
        // synchronously perform softUpdate to ensure high-tier data is available where expected
        let properties: PostProperties = .init(api: item.api, snapshot: apiType)
        Task {
            await item.updateQueue.attemptDirectUpdate(with: properties)
        }
        item.softUpdate(with: properties)
    }
}
