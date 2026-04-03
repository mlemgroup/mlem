//
//  ActionSeed+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 2026-04-02.
//

import Actions

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
}
