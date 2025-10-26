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
    .delete
]

private let moderationSeeds: [ActionSeed] = [
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
    ) where Content == CommentEllipsisMenuContent {
        self.icon = icon
        self.size = size

        self.content = CommentEllipsisMenuContent(comment: comment)
    }
}

struct CommentEllipsisMenuContent: View {
    let comment: any Comment1Providing

    var body: some View {
        ControlGroup {
            ActionButtons { _ in
                seeds.compactMap { $0.createAction(comment) }
            }
        }
        .controlGroupStyle(.compactMenu)
        Section {
            ActionButtons { _ in
                moderationSeeds.compactMap { $0.createAction(comment) }
            }
        }
    }
}
