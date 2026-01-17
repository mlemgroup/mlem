//
//  Comment2Providing.swift
//
//
//  Created by Sjmarf on 24/06/2024.
//

import Foundation

public protocol Comment2Providing: Comment1Providing, Interactable2Providing, PersonContentProviding, RemovableProviding {
    var comment2: Comment2 { get }
    
    var creator: any Person { get }
    var post: Post { get }
    var community: any Community { get }
    var creatorIsModerator: Bool { get }
    var creatorIsAdmin: Bool { get }
    var creatorBannedFromCommunity: Bool { get }
}

public extension Comment2Providing {
    var comment1: Comment1 { comment2.comment1 }

    var creator: any Person { comment2.creator }
    var post: Post { comment2.post }
    var community: any Community { comment2.community }
    var votes: VotesModel { comment2.votes }
    var saved: Bool { comment2.saved }
    var creatorIsModerator: Bool { comment2.creatorIsModerator }
    var creatorIsAdmin: Bool { comment2.creatorIsAdmin }
    var creatorBannedFromCommunity: Bool { comment2.creatorBannedFromCommunity }
    var commentCount: Int { comment2.commentCount }
    
    var creator_: (any Person)? { comment2.creator }
    var post_: Post? { comment2.post }
    var community_: (any Community)? { comment2.community }
    var votes_: VotesModel? { comment2.votes }
    var saved_: Bool? { comment2.saved }
    var creatorIsModerator_: Bool? { comment2.creatorIsModerator }
    var creatorIsAdmin_: Bool? { comment2.creatorIsAdmin }
    var creatorBannedFromCommunity_: Bool? { comment2.creatorBannedFromCommunity }
    var commentCount_: Int? { comment2.commentCount }
}

public extension Comment2Providing {
    func upgrade() async throws -> any Comment { self }
    
    func updateVote(_ newValue: ScoringOperation) {
        comment2.votes = comment2.votes.applyScoringOperation(operation: newValue)
        Task {
            await updateQueue.addItem {
                try await self.api.repository.voteOnComment(id: self.id, score: newValue)
            }
        }
    }
    
    func updateSaved(_ newValue: Bool) {
        comment2.saved = newValue
        Task {
            await updateQueue.addItem {
                try await self.api.repository.saveComment(id: self.id, save: newValue)
            }
        }
    }
    
    func getVotes(page: Int, limit: Int) async throws -> [PersonVote] {
        try await api.getCommentVotes(id: id, communityId: community.id, page: page, limit: limit)
    }
}

// PersonContentProviding conformance
public extension Comment2Providing {
    var userContent: PersonContent { .init(wrappedValue: .comment(comment2)) }
}

// CanModerateProviding conformance
public extension Comment2Providing {
    var canModerate: Bool {
        api.myPerson?.moderates(communityId: community.id) ?? false || api.isAdmin
    }
}
