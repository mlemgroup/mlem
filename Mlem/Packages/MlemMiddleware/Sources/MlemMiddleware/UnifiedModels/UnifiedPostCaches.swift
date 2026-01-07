//
//  UnifiedPostCaches.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2026-01-03.
//

// TODO: NOW generic PostSnapshot
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
    
    var value: any PostSnapshotProviding {
        switch self {
        case let .post1(snapshot): snapshot
        case let .post2(snapshot): snapshot
        case let .post3(snapshot): snapshot
        }
    }
}

class UnifiedPostCache: ApiTypeBackedCache<UnifiedPostModel, AnyPostSnapshot> {
    override func performModelTranslation(api: ApiClient, from apiType: AnyPostSnapshot) -> UnifiedPostModel {
        let creator: (any Person)?
        let community: (any Community)?
        
        switch apiType {
        case .post1:
            creator = nil
            community = nil
        case let .post2(snapshot):
            creator = api.caches.person1.getModel(api: api, from: snapshot.creator)
            community = api.caches.community1.getModel(api: api, from: snapshot.community)
        case let .post3(snapshot):
            creator = api.caches.person1.getModel(api: api, from: snapshot.post.creator)
            community = api.caches.community1.getModel(api: api, from: snapshot.post.community)
        }
        
        return .init(
            api: api,
            snapshot: apiType.value,
            creator: creator,
            community: community)
    }
    
    override func updateModel(_ item: UnifiedPostModel, with apiType: AnyPostSnapshot, semaphore: UInt? = nil) {
        // TODO: unified models figure out what to do with this function
        Task {
            await item.updateQueue.attemptDirectUpdate(with: .init(snapshot: apiType.value))
        }
    }
}
