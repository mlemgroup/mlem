//
//  ContextMenu+Post.swift
//  Mlem
//
//  Created by Sjmarf on 2025-12-23.
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
    .hide,
    .createImage,
    .report,
    .blockCreator,
    .edit,
    .delete
]

private let moderationSeeds: [ActionSeed] = [
    .pin,
    .lock,
    .markNsfw,
    .viewVotes,
    .remove,
    .banCreator,
    .purge,
    .purgeCreator
]

extension View {
    func contextMenu(post: any Post1Providing) -> some View {
        contextMenu {
            ActionButtons { _ in
                seeds.compactMap { $0.createAction(post) }
            }
        }
    }
}

extension EllipsisMenu {
    init(
        icon: Icon = .general.menu,
        size: CGFloat,
        post: any Post1Providing,
        type: Set<PostEllipsisMenuContent.ActionListType> = [.basic, .moderator]
    ) where Content == PostEllipsisMenuContent {
        self.icon = icon
        self.size = size

        self.content = PostEllipsisMenuContent(post: post, type: type)
    }
}

struct PostEllipsisMenuContent: View {
    enum ActionListType {
        case basic, moderator
    }

    let post: any Post1Providing
    let type: Set<ActionListType>

    var body: some View {
        if type.contains(.basic) {
            ControlGroup {
                ActionButtons { _ in
                    seeds.compactMap { $0.createAction(post) }
                }
            }
            .controlGroupStyle(.compactMenu)
        }
        if type.contains(.moderator) {
            Section {
                ActionButtons { _ in
                    moderationSeeds.compactMap { $0.createAction(post) }
                }
            }
        }
    }
}
