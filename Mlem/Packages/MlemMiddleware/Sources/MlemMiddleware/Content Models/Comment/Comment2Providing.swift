//
//  Comment2Providing.swift
//
//
//  Created by Sjmarf on 24/06/2024.
//

import Foundation

public protocol Comment2Providing: Comment1Providing, Interactable2Providing, PersonContentProviding {
    var comment2: Comment2 { get }
    
    var creator: any Person { get }
    var post: Post1 { get }
    var community: any Community { get }
    var creatorIsModerator: Bool? { get }
    var creatorIsAdmin: Bool? { get }
    var bannedFromCommunity: Bool { get }
}

public extension Comment2Providing {
    var comment1: Comment1 { comment2.comment1 }
    
    var creator: any Person { comment2.creator }
    var post: Post1 { comment2.post }
    var community: any Community { comment2.community }
    var votes: VotesModel { comment2.votes }
    var saved: Bool { comment2.saved }
    var creatorIsModerator: Bool? { comment2.creatorIsModerator }
    var creatorIsAdmin: Bool? { comment2.creatorIsAdmin }
    var bannedFromCommunity: Bool { comment2.bannedFromCommunity }
    var commentCount: Int { comment2.commentCount }
    
    var creator_: (any Person)? { comment2.creator }
    var post_: Post1? { comment2.post }
    var community_: (any Community)? { comment2.community }
    var votes_: VotesModel? { comment2.votes }
    var saved_: Bool? { comment2.saved }
    var creatorIsModerator_: Bool? { comment2.creatorIsModerator }
    var creatorIsAdmin_: Bool? { comment2.creatorIsAdmin }
    var bannedFromCommunity_: Bool? { comment2.bannedFromCommunity }
    var commentCount_: Int? { comment2.commentCount }
}

public extension Comment2Providing {
    private var votesManager: StateManager<VotesModel> { comment2.votesManager }
    private var savedManager: StateManager<Bool> { comment2.savedManager }
    
    func upgrade() async throws -> any Comment { self }
    
    @discardableResult
    func updateVote(_ newValue: ScoringOperation) -> Task<StateUpdateResult, Never> {
        votesManager.performRequest(expectedResult: votes.applyScoringOperation(operation: newValue)) { semaphore in
            try await self.api.voteOnComment(id: self.id, score: newValue, semaphore: semaphore)
        }
    }
    
    @discardableResult
    func updateSaved(_ newValue: Bool) -> Task<StateUpdateResult, Never> {
        savedManager.performRequest(expectedResult: newValue) { semaphore in
            try await self.api.saveComment(id: self.id, save: newValue, semaphore: semaphore)
        }
    }
    
    func getVotes(page: Int, limit: Int) async throws -> [PersonVote] {
        try await api.getCommentVotes(id: id, communityId: community.id, page: page, limit: limit)
    }
}

/// PersonContentProviding conformance
public extension Comment2Providing {
    var userContent: PersonContent { .init(wrappedValue: .comment(comment2)) }
}
