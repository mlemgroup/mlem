//
//  ContextMenu+InboxNotification.swift
//  Mlem
//
//  Created by Sjmarf on 2025-11-07.
//  

import Actions
import MlemMiddleware
import SwiftUI

private struct InboxNotificationContextMenuViewModifier: ViewModifier {
    @Environment(NavigationLayer.self) var navigation
    @Setting(\.interactionBar_reply) var replyBarConfiguration

    let notification: InboxNotification

    func body(content: Content) -> some View {
        content
            .contextMenu {
                ActionButtons { _ in
                    self.createActions(seeds: replyBarConfiguration.contextMenu)
                }
                Section {
                    Button("More...", icon: .general.menu) {
                        navigation.openSheet(.actionSheet(sheetSections, configuration: \.interactionBar_reply))
                    }
                    .symbolVariant(.circle)
                }
        }
    }

    var sheetSections: [ActionSheetSection] {
        ReplyBarConfiguration.availableActions.sections.map { seeds in
            .init(actions: self.createActions(seeds: seeds))
        }
    }

    func createActions(seeds: [ActionSeed]) -> [any Actions.Action] {
        seeds.compactMap {
            $0.createAction(notification) ?? $0.createAction(notification.content.wrappedValue)
        }
    }
}

extension View {
    func contextMenu(notification: InboxNotification) -> some View {
        modifier(InboxNotificationContextMenuViewModifier(notification: notification))
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
