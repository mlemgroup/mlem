//
//  CommunityCache.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-01.
//

import Foundation

public enum AnyCommunitySnapshot: CacheIdentifiable {
    case community1(Community1Snapshot)
    case community2(Community2Snapshot)
    case community3(Community3Snapshot)
    
    public var cacheId: Int {
        switch self {
        case let .community1(snapshot): snapshot.cacheId
        case let .community2(snapshot): snapshot.cacheId
        case let .community3(snapshot): snapshot.cacheId
        }
    }
}

class CommunityCache: ApiTypeBackedCache<Community, AnyCommunitySnapshot> {
    override func performModelTranslation(api: ApiClient, from apiType: AnyCommunitySnapshot) -> Community {
        return .init(api: api, properties: .init(api: api, snapshot: apiType))
    }
    
    override func updateModel(_ item: Community, with apiType: AnyCommunitySnapshot, semaphore: UInt? = nil) {
        // attempt a direct update through the queue to avoid overwriting more recent data, and also
        // synchronously perform softUpdate to ensure high-tier data is available where expected
        let properties: CommunityProperties = .init(api: item.api, snapshot: apiType)
        Task {
            await item.updateQueue.attemptDirectUpdate(with: properties)
        }
        item.softUpdate(with: properties)
    }
}

// TODO: NOW remove below this point

class Community1Cache: ApiTypeBackedCache<Community1, Community1Snapshot> {
    @MainActor
    override func performModelTranslation(api: ApiClient, from snapshot: Community1Snapshot) -> Community1 {
        .init(
            api: api,
            actorId: snapshot.actorId,
            id: snapshot.id,
            name: snapshot.name,
            created: snapshot.created,
            instanceId: snapshot.instanceId,
            updated: snapshot.updated,
            displayName: snapshot.displayName,
            description: snapshot.description,
            removed: snapshot.removed,
            deleted: snapshot.deleted,
            nsfw: snapshot.nsfw,
            avatar: snapshot.avatar,
            banner: snapshot.banner,
            hidden: snapshot.hidden,
            onlyModeratorsCanPost: snapshot.onlyModeratorsCanPost,
            blocked: nil
        )
    }
    
    @MainActor
    override func updateModel(_ item: Community1, with snapshot: Community1Snapshot, semaphore: UInt? = nil) {
        item.update(with: snapshot)
    }
}

class Community2Cache: ApiTypeBackedCache<Community2, Community2Snapshot> {
    @MainActor
    override func performModelTranslation(api: ApiClient, from snapshot: Community2Snapshot) -> Community2 {
        .init(
            api: api,
            community1: api.caches.community1.getModel(api: api, from: snapshot.community),
            subscription: snapshot.subscription,
            postCount: snapshot.postCount,
            commentCount: snapshot.commentCount,
            activeUserCount: snapshot.activeUserCount,
            bannedFromCommunity: snapshot.bannedFromCommunity
        )
    }
    
    @MainActor
    override func updateModel(_ item: Community2, with snapshot: Community2Snapshot, semaphore: UInt? = nil) {
        item.update(with: snapshot, semaphore: semaphore)
    }
}

class Community3Cache: ApiTypeBackedCache<Community3, Community3Snapshot> {
    @MainActor
    override func performModelTranslation(api: ApiClient, from snapshot: Community3Snapshot) -> Community3 {
        .init(
            api: api,
            community2: api.caches.community2.getModel(api: api, from: snapshot.community),
            instance: api.caches.instance1.getOptionalModel(api: api, from: snapshot.instance),
            moderators: api.caches.person.getModels(api: api, from: snapshot.moderators.map { .person1($0) }),
            discussionLanguageIds: snapshot.discussionLanguageIds
        )
    }
    
    @MainActor
    override func updateModel(_ item: Community3, with snapshot: Community3Snapshot, semaphore: UInt? = nil) {
        item.update(with: snapshot, semaphore: semaphore)
    }
}
