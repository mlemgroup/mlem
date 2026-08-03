//
//  VoteAction.swift
//  Mlem
//
//  Created by Sjmarf on 2025-10-25.
//

import Actions
import MlemMiddleware
import SwiftUI

struct VoteAction: Actions.Action {
    let entity: any InteractableProviding
    let type: ScoringOperation
}

// MARK: - Configurability

extension ActionSeed {
    static let upvote = ActionSeed("upvote", appearance: VoteAction.upvoteAppearance) {
        createVoteAction($0, type: .upvote)
    }
    static let downvote = ActionSeed("downvote", appearance: VoteAction.downvoteAppearance) {
        createVoteAction($0, type: .downvote)
    }
}

private func createVoteAction(_ entity: Any, type: ScoringOperation) -> VoteAction? {
    switch entity {
    case let entity as any InteractableProviding: VoteAction(entity: entity, type: type)
    default: nil
    }
}

// MARK: - Appearance

extension VoteAction {
    static let upvoteAppearance: ActionAppearance = .init(
        currentStateLabel: .init("Not Upvoted", icon: .lemmy.upvoted),
        stateTransitionLabel: .init("Upvote", icon: .lemmy.addUpvote),
        color: .themedUpvote
    )
    static let downvoteAppearance: ActionAppearance = .init(
        currentStateLabel: .init("Not Downvoted", icon: .lemmy.downvoted),
        stateTransitionLabel: .init("Downvote", icon: .lemmy.addDownvote),
        color: .themedDownvote
    )
    static let removeUpvoteAppearance: ActionAppearance = .init(
        currentStateLabel: .init("Upvoted", icon: .lemmy.upvoted),
        stateTransitionLabel: .init("Remove Upvote", icon: .lemmy.removeUpvote),
        color: .themedUpvote,
        prominent: true
    )
    static let removeDownvoteAppearance: ActionAppearance = .init(
        currentStateLabel: .init("Downvote", icon: .lemmy.downvoted),
        stateTransitionLabel: .init("Remove Downvote", icon: .lemmy.removeDownvote),
        color: .themedDownvote,
        prominent: true
    )

    func createAppearance(environment: EnvironmentValues) -> ActionAppearance {
        guard let votes = entity.votes.value else { return Self.upvoteAppearance.withVisibility(.hidden) }
        let hasMatchingVote = votes.myVote == type

        guard type != .none else {
            assertionFailure()
            return Self.upvoteAppearance
        }

        return baseAppearance(hasMatchingVote: hasMatchingVote).withVisibility(visibility(environment))
    }

    private func baseAppearance(hasMatchingVote: Bool) -> ActionAppearance {
        switch (type, hasMatchingVote) {
        case (.upvote, false): return Self.upvoteAppearance
        case (.upvote, true): return Self.removeUpvoteAppearance
        case (.downvote, false): return Self.downvoteAppearance
        case (.downvote, true): return Self.removeDownvoteAppearance
        default: return Self.upvoteAppearance
        }
    }

    private func visibility(_ environment: EnvironmentValues) -> ActionVisiblity {
        guard entity.api.canInteract(appState: environment.appState) else { return .hidden }

        let voteFederationMode = entity.api.voteFederationMode

        switch (self.type, entity is Post) {
        case (.upvote, true):
            return voteFederationMode.postUpvote == .all ? .enabled : .hidden
        case (.downvote, true):
            return voteFederationMode.postDownvote == .all ? .enabled : .hidden
        case (.upvote, false):
            return voteFederationMode.commentUpvote == .all ? .enabled : .hidden
        case (.downvote, false):
            return voteFederationMode.commentDownvote == .all ? .enabled : .hidden
        default:
            assertionFailure()
            return .hidden
        }
    }
}

// MARK: - Behavior

extension VoteAction {
    @MainActor
    func execute(environment: EnvironmentValues) {
        guard let toggleVote = entity.toggleVote else { return }
        toggleVote(type, [.haptic])
    }
}
