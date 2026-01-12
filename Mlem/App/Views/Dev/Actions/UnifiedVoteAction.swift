//
//  UnifiedVoteAction.swift
//  Mlem
//
//  Created by Eric Andrews on 2026-01-04.
//

import Actions
import MlemMiddleware
import SwiftUI
import os

struct UnifiedVoteAction: SimpleLabelAction {
    let entity: UnifiedPostModel
    let type: ScoringOperation
}

// MARK: - Configurability

extension ActionSeed {
    static let unifiedUpvote = ActionSeed("unifiedUpvote") { createVoteAction($0, type: .upvote) }
    // static let downvote = ActionSeed("downvote") { createVoteAction($0, type: .downvote) }
}

private func createVoteAction(_ entity: Any, type: ScoringOperation) -> UnifiedVoteAction? {
    switch entity {
    case let entity as UnifiedPostModel: UnifiedVoteAction(entity: entity, type: type)
    default: nil
    }
}

// MARK: - Appearance

extension UnifiedVoteAction {
    static let upvoteLabel: ActionLabel = .init(
        "Upvote",
        icon: .lemmy.upvoted.representingState(active: false),
        color: .themedUpvote
    )
    static let downvoteLabel: ActionLabel = .init(
        "Downvote",
        icon: .lemmy.downvoted.representingState(active: false),
        color: .themedDownvote
    )
    static let removeUpvoteLabel: ActionLabel = .init(
        "Upvoted",
        icon: .lemmy.upvoted.representingState(active: true),
        color: .themedUpvote
    )
    static let removeDownvoteLabel: ActionLabel = .init(
        "Downvoted",
        icon: .lemmy.downvoted.representingState(active: true),
        color: .themedDownvote
    )
    
    static var label: ActionLabel { upvoteLabel }

    func createLabel(environment: EnvironmentValues) -> ActionLabel {
        // TODO: NOW better way to handle this
        guard let votes = entity.votes.value else { return Self.upvoteLabel }
        let hasMatchingVote = votes.myVote == type

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

        let voteFederationMode = entity.api.voteFederationMode

        switch (self.type, entity is UnifiedPostModel) {
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

extension UnifiedVoteAction {
    @MainActor
    func execute(environment: EnvironmentValues) {
        environment.hapticManager.play(haptic: .lightSuccess, tier: .low)
        if let toggleVote = entity.toggleVote {
            toggleVote(type)
        }
    }
}
