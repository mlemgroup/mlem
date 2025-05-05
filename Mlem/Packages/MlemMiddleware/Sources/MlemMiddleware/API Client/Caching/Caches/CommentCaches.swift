//
//  CommentCaches.swift
//
//
//  Created by Sjmarf on 24/06/2024.
//

import Foundation

class Comment1Cache: ApiTypeBackedCache<Comment1, ApiComment> {
    override func performModelTranslation(api: ApiClient, from apiType: ApiComment) -> Comment1 {
        .init(
            api: api,
            actorId: apiType.apId,
            id: apiType.id,
            content: apiType.content,
            removed: apiType.removed,
            created: apiType.published,
            updated: apiType.updated,
            deleted: apiType.deleted,
            creatorId: apiType.creatorId,
            postId: apiType.postId,
            parentCommentIds: Array(apiType.path.split(separator: ".").compactMap { Int($0) }.dropFirst().dropLast()),
            distinguished: apiType.distinguished,
            languageId: apiType.languageId
        )
    }
    
    override func updateModel(_ item: Comment1, with apiType: ApiComment, semaphore: UInt? = nil) {
        item.update(with: apiType)
    }
}

class Comment2Cache: ApiTypeBackedCache<Comment2, ApiCommentView> {
    override func performModelTranslation(api: ApiClient, from apiType: ApiCommentView) -> Comment2 {
        let votesManager: StateManager<VotesModel>
        let savedManager: StateManager<Bool>
        
        if let comment = api.caches.reply2.retrieveModel(commentId: apiType.id) {
            votesManager = comment.votesManager
            savedManager = comment.savedManager
        } else {
            let votes: VotesModel
            if let counts = apiType.counts {
                votes = .init(
                    from: counts,
                    myVote: ScoringOperation.guaranteedInit(from: apiType.myVote)
                )
            } else {
                votes = .init(upvotes: 0, downvotes: 0, myVote: .none)
            }
            votesManager = .init(wrappedValue: votes)
            savedManager = .init(wrappedValue: apiType.saved ?? false)
        }
        
        return .init(
            api: api,
            comment1: api.caches.comment1.getModel(api: api, from: apiType.comment),
            creator: api.caches.person1.getModel(api: api, from: apiType.creator),
            post: api.caches.post1.getModel(api: api, from: apiType.post),
            community: api.caches.community1.getModel(api: api, from: apiType.community),
            votesManager: votesManager,
            savedManager: savedManager,
            creatorIsModerator: apiType.creatorIsModerator,
            creatorIsAdmin: apiType.creatorIsAdmin,
            bannedFromCommunity: apiType.creatorBannedFromCommunity ?? false,
            commentCount: apiType.counts?.childCount ?? 0
        )
    }
    
    override func updateModel(_ item: Comment2, with apiType: ApiCommentView, semaphore: UInt? = nil) {
        item.update(with: apiType, semaphore: semaphore)
    }
}
