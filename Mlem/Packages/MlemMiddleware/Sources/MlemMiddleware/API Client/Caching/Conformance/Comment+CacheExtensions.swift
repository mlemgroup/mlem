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
    func update(with comment: ApiComment, semaphore: UInt? = nil) {
        setIfChanged(\.content, comment.content)
        setIfChanged(\.created, comment.published)
        setIfChanged(\.updated, comment.updated)
        setIfChanged(\.distinguished, comment.distinguished)
        setIfChanged(\.languageId, comment.languageId)

        deletedManager.updateWithReceivedValue(comment.deleted, semaphore: semaphore)
        removedManager.updateWithReceivedValue(comment.removed, semaphore: semaphore)
    }
}

extension Comment2: CacheIdentifiable {
    public var cacheId: Int { id }
    
    @MainActor
    func update(with comment: ApiCommentView, semaphore: UInt? = nil) {
        setIfChanged(\.creatorIsModerator, comment.creatorIsModerator)
        setIfChanged(\.creatorIsAdmin, comment.creatorIsAdmin)
        creator.updateKnownCommunityBanState(id: community.id, banned: comment.creatorBannedFromCommunity)
        setIfChanged(\.commentCount, comment.counts.childCount)

        votesManager.updateWithReceivedValue(
            .init(from: comment.counts, myVote: ScoringOperation.guaranteedInit(from: comment.myVote)),
            semaphore: semaphore
        )
        savedManager.updateWithReceivedValue(comment.saved ?? false, semaphore: semaphore)
        
        comment1.update(with: comment.comment, semaphore: semaphore)
        creator.update(with: comment.creator, semaphore: semaphore)
        post.update(with: comment.post, semaphore: semaphore)
        community.update(with: comment.community, semaphore: semaphore)
    }
}
