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
    .markRead,
    .share,
    .blockCreator,
    .report
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
                Section {
                    Button("More...", icon: .general.menu) {
                        navigation.openSheet(.actionSheet(sheetSections))
                    }
                    .symbolVariant(.circle)
                }
        }
    }

    var sheetSections: [ActionSheetSection] {
        [
            .init(actions: createActions(seeds: [
                .upvote,
                .downvote,
                .save,
                .reply,
                .markRead,
                .selectText,
                .share,
                .report,
                .edit,
                .delete
            ])),
            .init(actions: createActions(seeds: [
                .blockCreator,
                .copyAuthorName,
                .openCreatorModlog
            ]))
        ]
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
}
