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
                    replyBarConfiguration.contextMenu.compactMap {
                        $0.createAction(notification) ?? $0.createAction(notification.content.wrappedValue)
                    }
                }
                Section {
                    Button("More...", icon: .general.menu) {
                        navigation.openSheet(.actionSheet(sheetSections))
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
            leading: configuration.swipes.leading.compactMap { $0.createAction(notification) },
            trailing: configuration.swipes.trailing.compactMap { $0.createAction(notification) }
        )
    }
}
