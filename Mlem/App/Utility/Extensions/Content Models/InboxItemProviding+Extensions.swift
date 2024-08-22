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
            appearance: .markRead(isOn: read),
            callback: api.canInteract ? { self.toggleRead(feedback: feedback) } : nil
        )
    }
}
