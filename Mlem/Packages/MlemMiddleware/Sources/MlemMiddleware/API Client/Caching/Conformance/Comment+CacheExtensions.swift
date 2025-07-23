//
//  Comment+CacheExtensions.swift
//
//
//  Created by Sjmarf on 24/06/2024.
//

import Foundation

extension Comment1: CacheIdentifiable {
    public var cacheId: Int { id }
    
    @MainActor
    func update(with snapshot: Comment1Snapshot, semaphore: UInt? = nil) {
        // If the comment is removed, the API returns an empty string
        // for the `comment/list` endpoint, but returns the comment content
        // in the modlog endpoint. This `if` statement prevents the comment
        // content being overwritten with that empty string.
        if !snapshot.removed {
            setIfChanged(\.content, snapshot.content)
        }
        setIfChanged(\.created, snapshot.created)
        setIfChanged(\.updated, snapshot.updated)
        setIfChanged(\.distinguished, snapshot.distinguished)
        setIfChanged(\.languageId, snapshot.languageId)

        deletedManager.updateWithReceivedValue(snapshot.deleted, semaphore: semaphore)
        removedManager.updateWithReceivedValue(snapshot.removed, semaphore: semaphore)
    }
}

extension Comment2: CacheIdentifiable {
    public var cacheId: Int { id }
    
    @MainActor
    func update(with snapshot: Comment2Snapshot, semaphore: UInt? = nil) {
        comment1.update(with: snapshot.comment, semaphore: semaphore)
        creator.update(with: snapshot.creator, semaphore: semaphore)
        
        // TODO: UpdateQueue remove this shim code
        post.post1.snapshot1Update(with: snapshot.post)
        
        community.update(with: snapshot.community, semaphore: semaphore)
        
        setIfChanged(\.commentCount, snapshot.commentCount)
        setIfChanged(\.creatorIsModerator, snapshot.creatorIsModerator)
        setIfChanged(\.creatorIsAdmin, snapshot.creatorIsAdmin)
        creator.updateKnownCommunityBanState(id: community.id, banned: snapshot.creatorBannedFromCommunity)

        votesManager.updateWithReceivedValue(snapshot.votes, semaphore: semaphore)
        savedManager.updateWithReceivedValue(snapshot.saved, semaphore: semaphore)
    }
}
