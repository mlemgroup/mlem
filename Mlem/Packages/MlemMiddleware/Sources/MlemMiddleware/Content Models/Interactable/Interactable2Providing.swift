//
//  Interactable2Providing.swift
//  Mlem
//
//  Created by Sjmarf on 17/02/2024.
//

import Foundation

// Content that can be upvoted, downvoted, saved etc
public protocol Interactable2Providing: Interactable1Providing, RemovableProviding, PurgableProviding {
    var creator: any Person { get }
    var community: any Community { get }
    var creatorIsModerator: Bool? { get }
    var creatorIsAdmin: Bool? { get }
    var creatorBannedFromCommunity: Bool { get }
    var commentCount: Int { get }
    var votes: VotesModel { get }
    var saved: Bool { get }
    
    @discardableResult
    func updateVote(_ newVote: ScoringOperation) -> Task<StateUpdateResult, Never>
    
    @discardableResult
    func updateSaved(_ newValue: Bool) -> Task<StateUpdateResult, Never>
    
    func reply(content: String, languageId: Int?) async throws -> Comment2
}

public extension Interactable2Providing {
    @discardableResult
    func toggleUpvoted() -> Task<StateUpdateResult, Never> {
        updateVote(votes.myVote == .upvote ? .none : .upvote)
    }
    
    @discardableResult
    func toggleDownvoted() -> Task<StateUpdateResult, Never> {
        updateVote(votes.myVote == .downvote ? .none : .downvote)
    }
    
    @discardableResult
    func toggleSaved() -> Task<StateUpdateResult, Never> {
        updateSaved(!saved)
    }
}
