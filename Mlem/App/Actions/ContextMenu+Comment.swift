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
    .purge,
    .purgeCreator
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
        comment: any Comment1Providing,
        type: Set<CommentEllipsisMenuContent.ActionListType> = [.basic, .moderator]
    ) where Content == CommentEllipsisMenuContent {
        self.icon = icon
        self.size = size

        self.content = CommentEllipsisMenuContent(comment: comment, type: type)
    }
}

struct CommentEllipsisMenuContent: View {
    enum ActionListType {
        case basic, moderator
    }

    let comment: any Comment1Providing
    let type: Set<ActionListType>

    var body: some View {
        if type.contains(.basic) {
            ControlGroup {
                ActionButtons { _ in
                    seeds.compactMap { $0.createAction(comment) }
                }
            }
            .controlGroupStyle(.compactMenu)
        }
        if type.contains(.moderator) {
            Section {
                ActionButtons { _ in
                    moderationSeeds.compactMap { $0.createAction(comment) }
                }
            }
        }
    }
}
