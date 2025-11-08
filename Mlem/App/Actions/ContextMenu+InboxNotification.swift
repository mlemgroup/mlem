//
//  ContextMenu+InboxNotification.swift
//  Mlem
//
//  Created by Sjmarf on 2025-11-07.
//  

import Actions
import MlemMiddleware
import SwiftUI

private let seeds: [ActionSeed] = [
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

extension View {
    func contextMenu(notification: InboxNotification) -> some View {
        contextMenu {
            ActionButtons { _ in
                seeds.compactMap {
                    $0.createAction(notification) ?? $0.createAction(notification.content.wrappedValue)
                }
            }
        }
    }
}
