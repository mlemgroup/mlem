//
//  ContextMenu+InboxNotification.swift
//  Mlem
//
//  Created by Sjmarf on 2025-11-07.
//  

import Actions
import Icons
import MlemMiddleware
import SwiftUI

extension View {
    func contextMenu(notification: InboxNotification) -> some View {
        contextMenu {
            CustomizableActionMenu(configuration: \.interactionBar_reply) { seed, _ in
                seed.createAction(notification) ?? seed.createAction(notification.content.wrappedValue)
            }
        }
    }

    func contextMenu(notification: InboxNotification?, message: any DeprecatedMessage, report: Report?) -> some View {
        contextMenu {
            CustomizableActionMenu(configuration: \.interactionBar_reply) { seed, _ in
                if let notification {
                    if let action = seed.createAction(notification) { return action }
                }
                if let report {
                    if let action = seed.createAction(report) { return action }
                }
                return seed.createAction(message)
            }
        }
    }

    @ViewBuilder
    func quickSwipes(notification: InboxNotification, configuration: ReplyBarConfiguration) -> some View {
        quickSwipes(
            leading: configuration.swipes.leading.compactMap { seed in
                seed.createAction(notification) ?? notification.content.comment.map { seed.createAction($0) } ?? nil
            },
            trailing: configuration.swipes.trailing.compactMap { seed in
                seed.createAction(notification) ?? notification.content.comment.map { seed.createAction($0) } ?? nil
            },
            leadingBuffer: .standard
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

extension EllipsisMenu {
    init(
        icon: Icon = .general.menu,
        size: CGFloat,
        notification: InboxNotification,
        type: Set<EllipsisMenuType> = [.basic, .moderator]
    ) where Content == CustomizableActionMenu<ReplyBarConfiguration> {
        self.icon = icon
        self.size = size

        self.content = CustomizableActionMenu(configuration: \.interactionBar_reply) { seed, _ in
            if seed.isModeratorAction {
                if !type.contains(.moderator) { return nil }
            } else {
                if !type.contains(.basic) { return nil }
            }

            return seed.createAction(notification) ?? seed.createAction(notification.content.wrappedValue)
        }
    }
}

extension EllipsisMenu {
    init(
        icon: Icon = .general.menu,
        size: CGFloat,
        message: any DeprecatedMessage,
        report: Report,
        type: Set<EllipsisMenuType> = [.basic, .moderator]
    ) where Content == CustomizableActionMenu<ReplyBarConfiguration> {
        self.icon = icon
        self.size = size

        self.content = CustomizableActionMenu(configuration: \.interactionBar_reply) { seed, _ in
            if seed.isModeratorAction {
                if !type.contains(.moderator) { return nil }
            } else {
                if !type.contains(.basic) { return nil }
            }

            return seed.createAction(report) ?? seed.createAction(message)
        }
    }
}
