//
//  CommentCaches.swift
//
//
//  Created by Sjmarf on 24/06/2024.
//

import Foundation

class Comment1Cache: ApiTypeBackedCache<Comment1, Comment1Snapshot> {
    override func performModelTranslation(api: ApiClient, from snapshot: Comment1Snapshot) -> Comment1 {
        .init(
            api: api,
            actorId: snapshot.actorId,
            id: snapshot.id,
            content: snapshot.content,
            removed: snapshot.removed,
            created: snapshot.created,
            updated: snapshot.updated,
            deleted: snapshot.deleted,
            creatorId: snapshot.creatorId,
            postId: snapshot.postId,
            parentCommentIds: snapshot.parentCommentIds,
            distinguished: snapshot.distinguished,
            languageId: snapshot.languageId
        )
    }
    
    override func updateModel(_ item: Comment1, with snapshot: Comment1Snapshot, semaphore: UInt? = nil) {
        // TODO: UpdateQueue move updateModel responsibilities fully out of the cache
    }
}

class Comment2Cache: ApiTypeBackedCache<Comment2, Comment2Snapshot> {
    override func performModelTranslation(api: ApiClient, from snapshot: Comment2Snapshot) -> Comment2 {
        .init(
            api: api,
            comment1: api.caches.comment1.getModel(api: api, from: snapshot.comment),
            creator: api.caches.person1.getModel(api: api, from: snapshot.creator),
            post: api.caches.post1.getModel(api: api, from: snapshot.post),
            community: api.caches.community1.getModel(api: api, from: snapshot.community),
            votes: snapshot.votes,
            saved: snapshot.saved,
            creatorIsModerator: snapshot.creatorIsModerator,
            creatorIsAdmin: snapshot.creatorIsAdmin,
            creatorBannedFromCommunity: snapshot.creatorBannedFromCommunity,
            commentCount: snapshot.commentCount
        )
    }
    
    override func updateModel(_ item: Comment2, with snapshot: Comment2Snapshot, semaphore: UInt? = nil) {
        // TODO: UpdateQueue move updateModel responsibilities fully out of the cache
    }
}
