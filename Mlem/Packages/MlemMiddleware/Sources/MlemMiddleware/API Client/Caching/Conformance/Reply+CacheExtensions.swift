//
//  Reply+CacheExtensions.swift
//
//
//  Created by Sjmarf on 04/07/2024.
//

import Foundation

extension Reply1: CacheIdentifiable {
    public var cacheId: Int {
        var hasher = Hasher()
        hasher.combine(id)
        hasher.combine(isMention)
        return hasher.finalize()
    }
    
    @MainActor
    func update(with snapshot: Reply1Snapshot, semaphore: UInt? = nil) {
        readManager.updateWithReceivedValue(snapshot.read, semaphore: semaphore)
    }
}

extension Reply2: CacheIdentifiable {
    @inlinable public var cacheId: Int { reply1.cacheId }
    
    @MainActor
    func update(with snapshot: Reply2Snapshot, semaphore: UInt? = nil) {
        reply1.update(with: snapshot.reply, semaphore: semaphore)
        creator.update(with: snapshot.creator)
        
        // TODO: UpdateQueue remove this shim code
        post.post1.snapshot1Update(with: snapshot.post)
        comment.comment1.snapshot1Update(with: snapshot.comment)
        
        community.update(with: snapshot.community)
        recipient.update(with: snapshot.recipient)
        
        setIfChanged(\.subscribed, snapshot.subscribed)
        setIfChanged(\.commentCount, snapshot.commentCount)
        setIfChanged(\.creatorIsModerator, snapshot.creatorIsModerator)
        setIfChanged(\.creatorIsAdmin, snapshot.creatorIsAdmin)
        creator.updateKnownCommunityBanState(id: community.id, banned: snapshot.creatorBannedFromCommunity)
        
        votesManager.updateWithReceivedValue(votes, semaphore: semaphore)
        savedManager.updateWithReceivedValue(saved, semaphore: semaphore)
    }
}
