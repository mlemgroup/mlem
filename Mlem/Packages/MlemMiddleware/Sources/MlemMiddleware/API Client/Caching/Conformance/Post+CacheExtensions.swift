//
//  Post+CacheExtensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-02.
//

import Foundation

extension Post1: CacheIdentifiable {
    public var cacheId: Int { id }
    
    @MainActor
    func update(with snapshot: Post1Snapshot, semaphore: UInt? = nil) {
        setIfChanged(\.title, snapshot.title)
        setIfChanged(\.content, snapshot.content)
        setIfChanged(\.linkUrl, snapshot.linkUrl)
        setIfChanged(\.updated, snapshot.updated)
        setIfChanged(\.embed, snapshot.embed)
        setIfChanged(\.nsfw, snapshot.nsfw)
        setIfChanged(\.thumbnailUrl, snapshot.thumbnailUrl)
        
        deletedManager.updateWithReceivedValue(snapshot.deleted, semaphore: semaphore)
        removedManager.updateWithReceivedValue(snapshot.removed, semaphore: semaphore)
        // pinnedCommunityManager.updateWithReceivedValue(snapshot.pinnedCommunity, semaphore: semaphore)
        pinnedInstanceManager.updateWithReceivedValue(snapshot.pinnedInstance, semaphore: semaphore)
        // lockedManager.updateWithReceivedValue(snapshot.locked, semaphore: semaphore)
    }
}

extension Post2: CacheIdentifiable {
    public var cacheId: Int { id }
    
    // TODO: NOW deprecate/move to different location; ensure setIfChanged used for snapshotUpdate methods
    @MainActor
    func update(with snapshot: Post2Snapshot, semaphore: UInt? = nil) {
        post1.update(with: snapshot.post, semaphore: semaphore)
        creator.update(with: snapshot.creator, semaphore: semaphore)
        community.update(with: snapshot.community, semaphore: semaphore)
        
        setIfChanged(\.commentCount, snapshot.commentCount)
        setIfChanged(\.unreadCommentCount, snapshot.unreadCommentCount)
        
        setIfChanged(\.creatorIsModerator, snapshot.creatorIsModerator)
        setIfChanged(\.creatorIsAdmin, snapshot.creatorIsAdmin)
        creator.updateKnownCommunityBanState(id: community.id, banned: snapshot.creatorBannedFromCommunity)
        
        // votes = snapshot.votes
//        savedManager.updateWithReceivedValue(snapshot.saved, semaphore: semaphore)
//        readManager.updateWithReceivedValue(snapshot.read, semaphore: semaphore)
        // hiddenManager.updateWithReceivedValue(snapshot.hidden, semaphore: semaphore)
        
        creator.blockedManager.updateWithReceivedValue(snapshot.creatorBlocked, semaphore: semaphore)
    }
}

extension Post3: CacheIdentifiable {
    public var cacheId: Int { id }
    
    @MainActor
    func update(with snapshot: Post3Snapshot, semaphore: UInt? = nil) {
        post2.update(with: snapshot.post, semaphore: semaphore)
        community.update(with: snapshot.community, semaphore: semaphore)
        
        setIfChanged(\.crossPosts, snapshot.crossPosts.map { crossPost in
            api.caches.post2.getModel(api: api, from: crossPost)
        })
    }
}
