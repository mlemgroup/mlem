//
//  ContextMenu+Comment.swift
//  Mlem
//
//  Created by Sjmarf on 2025-10-17.
//

import Actions
import Icons
import MlemMiddleware
import SwiftUI

private let seeds: [ActionSeed] = [
    .upvote,
    .downvote,
    .save,
    .reply,
    .selectText,
    .share,
    .report,
    .blockCreator,
    .edit,
    .delete,
    .viewVotes,
    .remove,
    .banCreator,
    .purge
]

extension View {
    func contextMenu(comment: any Comment1Providing) -> some View {
        contextMenu {
            ActionButtons { _ in
                seeds.compactMap { $0.createAction(comment) }
            }
        }
    }
}

extension EllipsisMenu {
    init(
        icon: Icon = .general.menu,
        size: CGFloat,
        comment: any Comment1Providing
    ) where Content == ActionButtons {
        self.icon = icon
        self.size = size

        self.content = ActionButtons { _ in
            seeds.compactMap { $0.createAction(comment) }
        }
    }
}
