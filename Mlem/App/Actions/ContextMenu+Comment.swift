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
    .createImage,
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
        comment: Comment,
        type: Set<CommentEllipsisMenuContent.ActionListType> = [.basic, .moderator]
    ) where Content == CommentEllipsisMenuContent {
        self.icon = icon
        self.size = size

        self.content = CommentEllipsisMenuContent(comment: comment, type: type)
    }
}

struct CommentEllipsisMenuContent: View {
    @Environment(\.reportContext) var reportContext: Report?
    
    enum ActionListType {
        case basic, moderator
    }

    let comment: Comment
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
                    var ret = moderationSeeds.compactMap { $0.createAction(comment) }
                    if let reportContext,
                       let resolveAction = ActionSeed.resolveReport.createAction(reportContext) {
                        ret.append(resolveAction)
                    }
                    return ret
                }
            }
        }
    }
}
