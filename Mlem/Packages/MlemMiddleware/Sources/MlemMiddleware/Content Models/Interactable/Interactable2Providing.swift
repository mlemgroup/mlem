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
    ShimInteractable2Providing {
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
    
    func reply(content: String, languageId: Int?) async throws -> Comment
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

// TODO: UnifiedCommentModel etc. incorporate this shim protocol into unified Interactable,
// get consistent about where feedback is passed in
public protocol ShimInteractable2Providing: RemovableProviding {
    var api: ApiClient { get }
    
    var votes: ExpectedValue<VotesModel> { get }
    var saved: ExpectedValue<Bool> { get }
    var commentCount: ExpectedValue<Int> { get }
    var creator: ExpectedValue<any Person> { get }
    var community: ExpectedValue<any Community> { get }
    var creatorIsAdmin: ExpectedValue<Bool> { get }
    var creatorIsModerator: ExpectedValue<Bool> { get }
    
    var toggleVote: ((ScoringOperation) -> Void)? { get }
    var updateVote: ((ScoringOperation) -> Void)? { get }
    var shimToggleUpvoted: (() -> Void)? { get }
    var shimToggleDownvoted: (() -> Void)? { get }
    var shimToggleSaved: (() -> Void)? { get }
}

public extension Interactable2Providing {
    var votes: ExpectedValue<VotesModel> {
        .init(
            value: self.votes,
            provideValue: { fatalError("This should not be called") })
    }

    var saved: ExpectedValue<Bool> {
        .init(
            value: self.saved,
            provideValue: { fatalError("This should not be called") }
        )
    }
    
    var commentCount: ExpectedValue<Int> {
        .init(
            value: self.commentCount,
            provideValue: { fatalError("This should not be called") })
    }
    
    var creator: ExpectedValue<any Person> {
        .init(
            value: self.creator,
            provideValue: { fatalError("This should not be called") })
    }
    
    var community: ExpectedValue<any Community> {
        .init(
            value: self.community,
            provideValue: { fatalError("This should not be called") })
    }
    
    var creatorIsAdmin: ExpectedValue<Bool> {
        .init(
            value: self.creatorIsAdmin,
            provideValue: { fatalError("This should not be called") })
    }
    
    var creatorIsModerator: ExpectedValue<Bool> {
        .init(
            value: self.creatorIsModerator,
            provideValue: { fatalError("This should not be called") })
    }
    
    var toggleVote: ((ScoringOperation) -> Void)? {
        { self.toggleVote(type: $0) }
    }
    
    var updateVote: ((ScoringOperation) -> Void)? {
        { self.updateVote($0) }
    }
    
    var shimToggleUpvoted: (() -> Void)? { toggleUpvoted }
    
    var shimToggleDownvoted: (() -> Void)? { toggleDownvoted }
    
    var shimToggleSaved: (() -> Void)? { toggleSaved }
}
