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
    var creatorIsModerator: Bool { get }
    var creatorIsAdmin: Bool { get }
    var creatorBannedFromCommunity: Bool { get }
    var commentCount: Int { get }
    var votes: VotesModel { get }
    var saved: Bool { get }
    
    func updateVote(_ newVote: ScoringOperation)
    
    func updateSaved(_ newValue: Bool)
    
    func reply(content: String, languageId: Int?) async throws -> Comment2
}

public extension Interactable2Providing {
    func toggleUpvoted() {
        updateVote(votes.myVote == .upvote ? .none : .upvote)
    }
    
    func toggleDownvoted() {
        updateVote(votes.myVote == .downvote ? .none : .downvote)
    }

    func toggleVote(type: ScoringOperation) {
        guard type != .none else {
            assertionFailure()
            return
        }
        updateVote(votes.myVote == type ? .none : type)
    }
    
    func toggleSaved() {
        updateSaved(!saved)
    }
}
