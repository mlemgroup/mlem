//
//  Reply2Providing.swift
//
//
//  Created by Sjmarf on 04/07/2024.
//

import Foundation

public protocol Reply2Providing: Reply1Providing, Interactable2Providing, ActorIdentifiable {
    var reply2: Reply2 { get }
    
    var actorId: ActorIdentifier { get }
    var reply1: Reply1 { get }
    var comment: Comment1 { get }
    var creator: any Person { get }
    var post: Post1 { get }
    var community: any Community { get }
    var recipient: Person1 { get }
    var subscribed: Bool { get }
    var commentCount: Int { get }
    var creatorIsModerator: Bool { get }
    var creatorIsAdmin: Bool { get }
    var creatorBannedFromCommunity: Bool { get }
    var removed: Bool { get }
}

public extension Reply2Providing {
    var reply1: Reply1 { reply2.reply1 }
    var actorId: ActorIdentifier { reply2.comment.actorId }
    var comment: Comment1 { reply2.comment }
    var creator: any Person { reply2.creator }
    var post: Post1 { reply2.post }
    var community: any Community { reply2.community }
    var recipient: Person1 { reply2.recipient }
    var subscribed: Bool { reply2.subscribed }
    var commentCount: Int { reply2.commentCount }
    var creatorIsModerator: Bool { reply2.creatorIsModerator }
    var creatorIsAdmin: Bool { reply2.creatorIsAdmin }
    var creatorBannedFromCommunity: Bool { reply2.creatorBannedFromCommunity }
    var removed: Bool { reply2.comment.removed }
    var removedPending: Bool { reply2.comment.removedPending }
    
    var reply1_: Reply1? { reply2.reply1 }
    var comment_: Comment1? { reply2.comment }
    var creator_: (any Person)? { reply2.creator }
    var post_: Post1? { reply2.post }
    var community_: (any Community)? { reply2.community }
    var recipient_: Person1? { reply2.recipient }
    var subscribed_: Bool? { reply2.subscribed }
    var commentCount_: Int? { reply2.commentCount }
    var creatorIsModerator_: Bool? { reply2.creatorIsModerator }
    var creatorIsAdmin_: Bool? { reply2.creatorIsAdmin }
    var creatorBannedFromCommunity_: Bool? { reply2.creatorBannedFromCommunity }
}

public extension Reply2Providing {
    private var votesManager: StateManager<VotesModel> { reply2.votesManager }
    private var savedManager: StateManager<Bool> { reply2.savedManager }
    
    func updateVote(_ newValue: ScoringOperation) throws {
        // TODO: UpdateQueue queued state management
        _ = votesManager.performRequest(expectedResult: votes.applyScoringOperation(operation: newValue)) { semaphore in
            try await self.api.voteOnComment(id: self.commentId, score: newValue, semaphore: semaphore)
        }
    }
    
    func updateSaved(_ newValue: Bool) throws {
        // TODO: UpdateQueue queued state management
        _ = savedManager.performRequest(expectedResult: newValue) { semaphore in
            try await self.api.saveComment(id: self.commentId, save: newValue, semaphore: semaphore)
        }
    }
    
    func reply(content: String, languageId: Int? = nil) async throws -> Comment2 {
        try await api.replyToComment(postId: post.id, parentId: commentId, content: content, languageId: languageId)
    }
    
    func updateRemoved(_ newValue: Bool, reason: String?, callback: ((Bool) -> Void)?) throws {
        try comment.updateRemoved(newValue, reason: reason, callback: callback)
    }
}
