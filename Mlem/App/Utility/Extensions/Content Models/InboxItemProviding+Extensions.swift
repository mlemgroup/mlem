//
//  InboxItemProviding+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 05/07/2024.
//

import MlemMiddleware

extension InboxItemProviding {
    func toggleRead(feedback: Set<FeedbackType>) {
        if feedback.contains(.haptic) {
            HapticManager.main.play(haptic: .lightSuccess, priority: .low)
        }
        toggleRead()
    }
    
    func markReadAction(feedback: Set<FeedbackType> = []) -> BasicAction {
        .init(
            id: "markRead\(uid)",
            appearance: .init(
                label: read ? "Mark Unread" : "Mark Read",
                isOn: read,
                color: Palette.main.read,
                icon: read ? Icons.markUnread : Icons.markRead,
                swipeIcon1: read ? Icons.markRead : Icons.markUnread,
                swipeIcon2: read ? Icons.markUnreadFill : Icons.markReadFill
            ),
            callback: api.canInteract ? { self.toggleRead(feedback: feedback) } : nil
        )
    }
}
