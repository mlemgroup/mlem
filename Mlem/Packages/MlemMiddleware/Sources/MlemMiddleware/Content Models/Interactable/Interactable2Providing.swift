//
//  Interactable2Providing.swift
//  Mlem
//
//  Created by Sjmarf on 17/02/2024.
//

import Foundation

// Content that can be upvoted, downvoted, saved etc
public protocol Interactable2Providing:
    Interactable1Providing,
    RemovableProviding,
    PurgableProviding,
    CanModerateProviding,
    ShimVotable,
    ShimSaveable {
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

// TODO: UnifiedCommentModel etc. remove these shims
public protocol ShimVotable {
    var api: ApiClient { get }
    var votes: ExpectedValue<VotesModel> { get }
    var toggleVote: ((ScoringOperation) -> Void)? { get }
}

public protocol ShimSaveable {
    var api: ApiClient { get }
    var saved: ExpectedValue<Bool> { get }
    var shimToggleSaved: (() -> Void)? { get }
}

public extension Interactable2Providing {
    var votes: ExpectedValue<VotesModel> {
        .init(
            getValue: { self.votes },
            provideValue: { assertionFailure("This should not be called") })
    }
    
    var toggleVote: ((ScoringOperation) -> Void)? {
        { self.toggleVote(type: $0) }
    }
    
    var saved: ExpectedValue<Bool> {
        .init(
            getValue: { self.saved },
            provideValue: { assertionFailure("This should not be called") }
        )
    }
    
    var shimToggleSaved: (() -> Void)? { toggleSaved }
}
