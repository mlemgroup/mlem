//
//  ReplyCaches.swift
//
//
//  Created by Sjmarf on 04/07/2024.
//

import Foundation

class Reply1Cache: CoreCache<Reply1> {
    @MainActor
    func getModel(api: ApiClient, from apiType: Reply1Backer, semaphore: UInt? = nil) -> Reply1 {
        if let item = retrieveModel(cacheId: apiType.cacheId) {
            item.update(with: apiType)
            return item
        }
        
        let newItem: Reply1 = .init(
            api: api,
            id: apiType.id,
            recipientId: apiType.recipientId,
            commentId: apiType.commentId,
            created: apiType.published,
            read: apiType.read,
            isMention: apiType is ApiPersonMention
        )

        itemCache.put(newItem)
        return newItem
    }
}

class Reply2Cache: CoreCache<Reply2> {
    public var commentIdItemCache: ItemCache = .init()
    
    @MainActor
    func getModel(api: ApiClient, from apiType: Reply2Backer, semaphore: UInt? = nil) -> Reply2 {
        if let item = retrieveModel(cacheId: apiType.cacheId) {
            item.update(with: apiType, semaphore: semaphore)
            return item
        }
        
        let votesManager: StateManager<VotesModel>
        let savedManager: StateManager<Bool>
        
        if let comment = api.caches.comment2.retrieveModel(cacheId: apiType.comment.id) {
            votesManager = comment.votesManager
            savedManager = comment.savedManager
        } else {
            votesManager = .init(wrappedValue: .init(
                from: apiType.counts,
                myVote: ScoringOperation.guaranteedInit(from: apiType.myVote)
            ))
            savedManager = .init(wrappedValue: apiType.resolvedSaved)
        }
        
        let newItem: Reply2 = .init(
            api: api,
            reply1: api.caches.reply1.getModel(api: api, from: apiType.reply),
            comment: api.caches.comment1.getModel(api: api, from: apiType.comment),
            creator: api.caches.person1.getModel(api: api, from: apiType.creator),
            post: api.caches.post1.getModel(api: api, from: apiType.post),
            community: api.caches.community1.getModel(api: api, from: apiType.community),
            recipient: api.caches.person1.getModel(api: api, from: apiType.recipient),
            subscribed: apiType.subscribed.isSubscribed,
            commentCount: apiType.counts.childCount,
            creatorIsModerator: apiType.creatorIsModerator,
            creatorIsAdmin: apiType.creatorIsAdmin,
            bannedFromCommunity: apiType.creatorBannedFromCommunity,
            votesManager: votesManager,
            savedManager: savedManager
        )

        itemCache.put(newItem)
        commentIdItemCache.put(newItem, overrideCacheId: newItem.commentId)
        return newItem
    }
    
    public func retrieveModel(commentId: Int) -> Reply2? {
        commentIdItemCache.get(commentId)
    }
    
    @MainActor
    func getModels(api: ApiClient, from apiTypes: [Reply2Backer], semaphore: UInt? = nil) -> [Reply2] {
        apiTypes.map { getModel(api: api, from: $0, semaphore: semaphore) }
    }
    
    override func clean() {
        Task {
            await itemCache.clean()
            await commentIdItemCache.clean()
        }
    }
}
