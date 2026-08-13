//
//  Message1Providing+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 05/07/2024.
//

import Haptics
import MlemMiddleware
import QuickSwipes

extension Message1Providing {
    func swipeActions(notification: InboxNotification?, appState: AppState) -> SwipeConfiguration {
        // If this is extended to add leading actions, make leadingBuffer a parameter
        .init(
            trailingActions: {
                if api.canInteract(appState: appState), !isOwnMessage, let notification {
                    markReadAction(appState: appState, notification: notification, feedback: [.haptic])
                }
            },
            leadingBuffer: .standard
        )
    }

    func markReadAction(appState: AppState, notification: InboxNotification, feedback: Set<FeedbackType> = []) -> BasicAction {
        .init(
            id: "markRead\(uid)",
            appearance: .markRead(isOn: notification.read),
            callback: api.canInteract(appState: appState) ? {
                @MainActor in
                notification.toggleRead()
                HapticManager.main.play(haptic: .lightSuccess, tier: .low)
            } : nil
        )
    }
}
