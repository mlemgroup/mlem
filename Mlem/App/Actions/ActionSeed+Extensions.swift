//
//  ActionSeed+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 2026-04-02.
//

import Actions
import MlemMiddleware

extension ActionSeed {
    private static let moderatorActions: Set<ActionSeed> = [
        .pin,
        .lock,
        .markNsfw,
        .viewVotes,
        .remove,
        .banCreator,
        .purge,
        .purgeCreator,
        .resolveReport
    ]

    var isModeratorAction: Bool {
        Self.moderatorActions.contains(self)
    }

    var isBasicAction: Bool {
        !Self.moderatorActions.contains(self)
    }
        
    func associatedReadouts(context: any InteractableProviding) -> Set<ReadoutType> {
        switch self {
        case .upvote: context.votes.value?.myVote ?? .none == .upvote ? [.upvote, .score] : [.upvote]
        case .downvote: context.votes.value?.myVote ?? .none == .downvote ? [.downvote, .score] : [.downvote]
        case .save: [.saved]
        default: []
        }
    }
}
