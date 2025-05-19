//
//  Community+CacheExtensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-02.
//

import Foundation

extension Community1: CacheIdentifiable {
    public var cacheId: Int { id }
    
    @MainActor
    func update(with community: Community1Snapshot, semaphore: UInt? = nil) {
        setIfChanged(\.updated, community.updated)
        setIfChanged(\.displayName, community.displayName)
        setIfChanged(\.description, community.description)
        setIfChanged(\.deleted, community.deleted)
        setIfChanged(\.nsfw, community.nsfw)
        setIfChanged(\.avatar, community.avatar)
        setIfChanged(\.banner, community.banner)
        setIfChanged(\.hidden, community.hidden)
        setIfChanged(\.onlyModeratorsCanPost, community.onlyModeratorsCanPost)
        setIfChanged(\.visibility, community.visibility)
        
        removedManager.updateWithReceivedValue(community.removed, semaphore: semaphore)
    }
}

extension Community2: CacheIdentifiable {
    public var cacheId: Int { id }
    
    @MainActor
    func update(with snapshot: Community2Snapshot, semaphore: UInt? = nil) {
        setIfChanged(\.postCount, snapshot.postCount)
        setIfChanged(\.commentCount, snapshot.commentCount)
        setIfChanged(\.activeUserCount, snapshot.activeUserCount)
        
        subscriptionManager.updateWithReceivedValue(
            snapshot.subscription,
            semaphore: semaphore
        )
        
        community1.update(with: snapshot.community, semaphore: semaphore)
    }
}

extension Community3: CacheIdentifiable {
    public var cacheId: Int { id }
    
    @MainActor
    func update(with snapshot: Community3Snapshot, semaphore: UInt? = nil) {
        setIfChanged(\.moderators, api.caches.person1.getModels(api: api, from: snapshot.moderators))
        setIfChanged(\.discussionLanguageIds, snapshot.discussionLanguageIds)

        community2.update(with: snapshot.community, semaphore: semaphore)
    }
}
