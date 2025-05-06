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
    func update(with backer: Community2Snapshot, semaphore: UInt? = nil) {
        setIfChanged(\.postCount, backer.postCount)
        setIfChanged(\.commentCount, backer.commentCount)
        setIfChanged(\.activeUserCount, backer.activeUserCount)
        
        subscriptionManager.updateWithReceivedValue(
            backer.subscription,
            semaphore: semaphore
        )
        
        community1.update(with: backer.community, semaphore: semaphore)
    }
}

extension Community3: CacheIdentifiable {
    public var cacheId: Int { id }
    
    @MainActor
    func update(with backer: Community3Snapshot, semaphore: UInt? = nil) {
        setIfChanged(\.moderators, api.caches.person1.getModels(api: api, from: backer.moderators))
        setIfChanged(\.discussionLanguageIds, backer.discussionLanguageIds)

        community2.update(with: backer.community, semaphore: semaphore)
    }
}
