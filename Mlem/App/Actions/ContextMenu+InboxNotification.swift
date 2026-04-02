//
//  ContextMenu+InboxNotification.swift
//  Mlem
//
//  Created by Sjmarf on 2025-11-07.
//  

import Actions
import MlemMiddleware
import SwiftUI

extension View {
    func contextMenu(notification: InboxNotification) -> some View {
        modifier(ActionContextMenuViewModifier(configuration: \.interactionBar_reply) { seed in
            seed.createAction(notification) ?? seed.createAction(notification.content.wrappedValue)
        })
    }

    @ViewBuilder
    func quickSwipes(notification: InboxNotification, configuration: ReplyBarConfiguration) -> some View {
        quickSwipes(
            leading: configuration.swipes.leading.compactMap { seed in
                seed.createAction(notification) ?? notification.content.comment.map { seed.createAction($0) } ?? nil
            },
            trailing: configuration.swipes.trailing.compactMap { seed in
                seed.createAction(notification) ?? notification.content.comment.map { seed.createAction($0) } ?? nil
            }
        )
    }
}

private extension InboxNotificationContent {
    var comment: Comment? {
        switch self {
        case let .reply(comment), let .mention(comment): comment
        default: nil
        }
    }
}
