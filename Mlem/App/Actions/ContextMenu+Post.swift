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
    func contextMenu(post: Post) -> some View {
        modifier(ActionContextMenuViewModifier(
            entity: post,
            configuration: \.interactionBar_post,
            modMailConfiguration: \.interactionBar_postReport,
            customizable: false
        ))
    }

    @ViewBuilder
    func quickSwipes(post: Post, configuration: PostBarConfiguration) -> some View {
        quickSwipes(
            leading: configuration.swipes.leading.compactMap { $0.createAction(post) },
            trailing: configuration.swipes.trailing.compactMap { $0.createAction(post) }
        )
    }
}

extension EllipsisMenu {
    init(
        icon: Icon = .general.menu,
        size: CGFloat,
        post: Post,
        type: Set<PostEllipsisMenuContent.ActionListType> = [.basic, .moderator]
    ) where Content == PostEllipsisMenuContent {
        self.icon = icon
        self.size = size

        self.content = PostEllipsisMenuContent(post: post, type: type)
    }
}

struct PostEllipsisMenuContent: View {
    @Environment(\.reportContext) var reportContext: Report?

    enum ActionListType {
        case basic, moderator
    }

    let post: Post
    let type: Set<ActionListType>

    var body: some View {
        Group {
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
                        var ret = moderationSeeds.compactMap { $0.createAction(post) }
                        if let reportContext,
                            let resolveAction = ActionSeed.resolveReport.createAction(reportContext) {
                            ret.append(resolveAction)
                        }
                        return ret
                    }
                }
            }
        }
        .environment(\.isContextMenu, true)
    }
}
