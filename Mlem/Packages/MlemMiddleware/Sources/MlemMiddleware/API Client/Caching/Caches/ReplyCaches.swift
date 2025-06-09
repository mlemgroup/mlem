//
//  ReplyCaches.swift
//
//
//  Created by Sjmarf on 04/07/2024.
//

import Foundation

class Reply1Cache: ApiTypeBackedCache<Reply1, Reply1Snapshot> {
    override func performModelTranslation(api: ApiClient, from snapshot: Reply1Snapshot) -> Reply1 {
        .init(
            api: api,
            id: snapshot.id,
            recipientId: snapshot.recipientId,
            commentId: snapshot.commentId,
            created: snapshot.created,
            read: snapshot.read,
            isMention: snapshot.isMention
        )
    }
    
    override func updateModel(_ item: Reply1, with snapshot: Reply1Snapshot, semaphore: UInt? = nil) {
        item.update(with: snapshot, semaphore: semaphore)
    }
}

class Reply2Cache: ApiTypeBackedCache<Reply2, Reply2Snapshot> {
    public var commentIdItemCache: ItemCache = .init()
    
    public func retrieveModel(commentId: Int) -> Reply2? {
        commentIdItemCache.get(commentId)
    }

    override func performModelTranslation(api: ApiClient, from snapshot: Reply2Snapshot) -> Reply2 {
        let votesManager: StateManager<VotesModel>
        let savedManager: StateManager<Bool>
        
        if let reply = api.caches.comment2.retrieveModel(cacheId: snapshot.comment.id) {
            votesManager = reply.votesManager
            savedManager = reply.savedManager
        } else {
            votesManager = .init(wrappedValue: snapshot.votes)
            savedManager = .init(wrappedValue: snapshot.saved)
        }
        
        let result: Reply2 = .init(
            api: api,
            reply1: api.caches.reply1.getModel(api: api, from: snapshot.reply),
            comment: api.caches.comment1.getModel(api: api, from: snapshot.comment),
            creator: api.caches.person1.getModel(api: api, from: snapshot.creator),
            post: api.caches.post1.getModel(api: api, from: snapshot.post),
            community: api.caches.community1.getModel(api: api, from: snapshot.community),
            recipient: api.caches.person1.getModel(api: api, from: snapshot.recipient),
            subscribed: snapshot.subscribed,
            commentCount: snapshot.commentCount,
            creatorIsModerator: snapshot.creatorIsModerator,
            creatorIsAdmin: snapshot.creatorIsAdmin,
            bannedFromCommunity: snapshot.creatorBannedFromCommunity,
            votesManager: votesManager,
            savedManager: savedManager
        )
        commentIdItemCache.put(result, overrideCacheId: snapshot.comment.id)
        return result
    }
    
    override func updateModel(_ item: Reply2, with snapshot: Reply2Snapshot, semaphore: UInt? = nil) {
        item.update(with: snapshot, semaphore: semaphore)
    }
    
    override func clean() {
        Task {
            await itemCache.clean()
            await commentIdItemCache.clean()
        }
    }
}
