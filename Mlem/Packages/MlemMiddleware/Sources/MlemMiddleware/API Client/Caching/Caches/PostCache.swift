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
        return .init(api: api, properties: enrichSnapshot(api: api, snapshot: apiType))
    }
    
    override func updateModel(_ item: Post, with apiType: AnyPostSnapshot, semaphore: UInt? = nil) {
        // this ensures that high-tier data is available where expected, but uses softUpdate to avoid overwriting
        // potentially more recent data
        item.properties.softUpdate(with: enrichSnapshot(api: item.api, snapshot: apiType))
    }
    
    @MainActor
    private func enrichSnapshot(api: ApiClient, snapshot: AnyPostSnapshot) -> PostProperties {
        let creator: (any Person)?
        let community: (any Community)?
        let crossPosts: [Post]?
        
        switch snapshot {
        case .post1:
            creator = nil
            community = nil
            crossPosts = nil
        case let .post2(snapshot):
            creator = api.caches.person1.getModel(api: api, from: snapshot.creator)
            community = api.caches.community1.getModel(api: api, from: snapshot.community)
            crossPosts = nil
        case let .post3(snapshot):
            creator = api.caches.person1.getModel(api: api, from: snapshot.post.creator)
            community = api.caches.community1.getModel(api: api, from: snapshot.post.community)
            crossPosts = api.caches.post.getModels(api: api, from: snapshot.crossPosts.map { .post2($0) })
        }
        
        return .init(snapshot: snapshot, creator: creator, community: community, crossPosts: crossPosts)
    }
}
