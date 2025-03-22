//
//  Reply+CacheExtensions.swift
//
//
//  Created by Sjmarf on 04/07/2024.
//

import Foundation

extension Reply1: CacheIdentifiable {
    public var cacheId: Int { id }
    
    @MainActor
    func update(with reply: any Reply1ApiBacker, semaphore: UInt? = nil) {
        readManager.updateWithReceivedValue(reply.read, semaphore: semaphore)
    }
}

extension Reply2: CacheIdentifiable {
    public var cacheId: Int { id }
    
    @MainActor
    func update(with reply: any Reply2ApiBacker, semaphore: UInt? = nil) {
        setIfChanged(\.subscribed, reply.subscribed.isSubscribed)
        setIfChanged(\.commentCount, reply.counts.childCount)
        setIfChanged(\.creatorIsModerator, reply.creatorIsModerator)
        setIfChanged(\.creatorIsAdmin, reply.creatorIsAdmin)
        creator.updateKnownCommunityBanState(id: community.id, banned: reply.creatorBannedFromCommunity)
        
        votesManager.updateWithReceivedValue(votes, semaphore: semaphore)
        savedManager.updateWithReceivedValue(saved, semaphore: semaphore)
        
        reply1.update(with: reply.reply, semaphore: semaphore)
        comment.update(with: reply.comment)
        creator.update(with: reply.creator)
        post.update(with: reply.post)
        community.update(with: reply.community)
        recipient.update(with: reply.recipient)
    }
}
