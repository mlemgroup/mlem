//
//  ContextMenu+InboxNotification.swift
//  Mlem
//
//  Created by Sjmarf on 2025-11-07.
//  

import Actions
import MlemMiddleware
import SwiftUI

private let topLevelSeeds: [ActionSeed] = [
    .reply,
    .markRead,
    .selectText
]

private let actionSheetSeeds: [ActionSeed] = [
    .upvote,
    .downvote,
    .save,
    .reply,
    .markRead,
    .selectText,
    .share,
    .blockCreator,
    .report,
    .edit,
    .delete
]

private struct InboxNotificationContextMenuViewModifier: ViewModifier {
    @Environment(NavigationLayer.self) var navigation

    let notification: InboxNotification

    func body(content: Content) -> some View {
        content
            .contextMenu {
                ActionButtons { _ in
                    topLevelSeeds.compactMap {
                        $0.createAction(notification) ?? $0.createAction(notification.content.wrappedValue)
                    }
                }
                Divider()
                Button("More...", icon: .general.menu) {
                    let actions = actionSheetSeeds.compactMap {
                        $0.createAction(notification) ?? $0.createAction(notification.content.wrappedValue)
                    }
                    navigation.openSheet(.actionSheet(actions))
                }
                .symbolVariant(.circle)
        }
    }
}

extension View {
    func contextMenu(notification: InboxNotification) -> some View {
        modifier(InboxNotificationContextMenuViewModifier(notification: notification))
    }
}
