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
        let creator: (any Person)?
        let community: (any Community)?
        let crossPosts: [Post]?
        
        switch apiType {
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
        
        return .init(
            api: api,
            snapshot: apiType,
            creator: creator,
            community: community,
            crossPosts: crossPosts)
    }
    
    override func updateModel(_ item: Post, with apiType: AnyPostSnapshot, semaphore: UInt? = nil) {
        // TODO: unified models figure out what to do with this function
        Task {
            await item.updateQueue.attemptDirectUpdate(with: .init(snapshot: apiType))
        }
    }
}
