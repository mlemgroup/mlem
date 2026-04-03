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
        type: Set<Content.ActionListType> = [.basic, .moderator]
    ) where Content == InteractableEllipsisMenuContent<PostBarConfiguration> {
        self.icon = icon
        self.size = size

        self.content = InteractableEllipsisMenuContent(entity: post, configuration: \.interactionBar_post, type: type)
    }
}
