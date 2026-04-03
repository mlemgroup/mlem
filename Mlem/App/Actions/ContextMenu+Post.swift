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
        contextMenu {
            CustomizableActionMenu(
                entity: post,
                configuration: \.interactionBar_post,
                modMailConfiguration: \.interactionBar_postReport,
                customizable: true
            )
        }
    }

    @ViewBuilder
    func quickSwipes(post: Post, configuration: PostBarConfiguration) -> some View {
        quickSwipes(
            leading: configuration.swipes.leading.compactMap { $0.createAction(post) },
            trailing: configuration.swipes.trailing.compactMap { $0.createAction(post) }
        )
    }
}

enum EllipsisMenuType {
    case basic, moderator
}

extension EllipsisMenu {
    init(
        icon: Icon = .general.menu,
        size: CGFloat,
        post: Post,
        type: Set<EllipsisMenuType> = [.basic, .moderator]
    ) where Content == CustomizableActionMenu<PostBarConfiguration> {
        self.icon = icon
        self.size = size

        self.content = CustomizableActionMenu(
            entity: post,
            configuration: \.interactionBar_post,
            modMailConfiguration: \.interactionBar_postReport,
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
