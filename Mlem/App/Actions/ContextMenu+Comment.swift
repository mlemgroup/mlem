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
    func contextMenu(comment: Comment) -> some View {
        contextMenu {
            CustomizableActionMenu(
                entity: comment,
                configuration: \.interactionBar_comment,
                modMailConfiguration: \.interactionBar_commentReport,
                customizable: true
            )
        }
        .popupAnchor()
    }

    @ViewBuilder
    func quickSwipes(comment: Comment, configuration: CommentBarConfiguration, leadingBuffer: SwipeBuffer) -> some View {
        quickSwipes(
            leading: configuration.swipes.leading.compactMap { $0.createAction(comment) },
            trailing: configuration.swipes.trailing.compactMap { $0.createAction(comment) },
            leadingBuffer: leadingBuffer
        )
    }
}

extension EllipsisMenu {
    init(
        icon: Icon = .general.menu,
        size: CGFloat,
        comment: Comment,
        type: Set<EllipsisMenuType> = [.basic, .moderator]
    ) where Content == CustomizableActionMenu<CommentBarConfiguration> {
        self.icon = icon
        self.size = size

        self.content = CustomizableActionMenu(
            entity: comment,
            configuration: \.interactionBar_comment,
            modMailConfiguration: \.interactionBar_commentReport,
            customizable: true
        ) { seed in
            if seed.isModeratorAction {
                return type.contains(.moderator)
            } else {
                return type.contains(.basic)
            }
        }
    }
}
