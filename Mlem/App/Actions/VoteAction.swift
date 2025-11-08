//
//  VoteAction.swift
//  Mlem
//
//  Created by Sjmarf on 2025-10-25.
//

import Actions
import MlemMiddleware
import SwiftUI

struct VoteAction: ConfigurableAction {
    let entity: any Interactable2Providing
    let type: ScoringOperation
}

// MARK: - Configurability

extension ActionSeed {
    static let upvote = ActionSeed("upvote") { createVoteAction($0, type: .upvote) }
    static let downvote = ActionSeed("downvote") { createVoteAction($0, type: .downvote) }
}

private func createVoteAction(_ entity: Any, type: ScoringOperation) -> VoteAction? {
    switch entity {
    case let entity as any Interactable2Providing: VoteAction(entity: entity, type: type)
    default: nil
    }
}

// MARK: - Appearance

extension VoteAction {
    static let upvoteLabel: ActionLabel = .init("Upvote", icon: .lemmy.upvoted.representingState(active: false))
    static let downvoteLabel: ActionLabel = .init("Downvote", icon: .lemmy.downvoted.representingState(active: false))
    static let removeUpvoteLabel: ActionLabel = .init("Upvoted", icon: .lemmy.upvoted.representingState(active: true))
    static let removeDownvoteLabel: ActionLabel = .init("Downvoted", icon: .lemmy.downvoted.representingState(active: true))
    
    static var label: ActionLabel { upvoteLabel }

    func createLabel(environment: EnvironmentValues) -> ActionLabel {
        let hasMatchingVote = entity.votes.myVote == type

        guard type != .none else {
            assertionFailure()
            return Self.upvoteLabel
        }

        return switch (type, hasMatchingVote) {
        case (.upvote, false): Self.upvoteLabel
        case (.upvote, true): Self.removeUpvoteLabel
        case (.downvote, false): Self.downvoteLabel
        case (.downvote, true): Self.removeDownvoteLabel
        default: Self.upvoteLabel
        }
    }

    private func visibility(_ environment: EnvironmentValues) -> ActionVisiblity {
        guard entity.api.canInteract(appState: environment.appState) else { return .hidden }

        if type == .downvote {
            guard entity.api.downvotesEnabled else { return .hidden }
        }

        return .enabled
    }
}

// MARK: - Behavior

extension VoteAction {
    @MainActor
    func execute(environment: EnvironmentValues) {
        environment.hapticManager.play(haptic: .lightSuccess, tier: .low)
        entity.toggleVote(type: type)
    }
}
