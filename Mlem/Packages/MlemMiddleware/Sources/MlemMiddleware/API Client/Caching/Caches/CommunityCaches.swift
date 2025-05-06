//
//  CommunityCaches.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-01.
//

import Foundation

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
            blocked: nil,
            visibility: snapshot.visibility
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
            moderators: api.caches.person1.getModels(api: api, from: snapshot.moderators),
            discussionLanguageIds: snapshot.discussionLanguageIds
        )
    }
    
    @MainActor
    override func updateModel(_ item: Community3, with snapshot: Community3Snapshot, semaphore: UInt? = nil) {
        item.update(with: snapshot, semaphore: semaphore)
    }
}
