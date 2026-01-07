//
//  InboxItemProviding+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 05/07/2024.
//

import Haptics
import MlemMiddleware

extension InboxItemProviding {    
    func toggleRead(feedback: Set<FeedbackType>) {
        if feedback.contains(.haptic) {
            HapticManager.main.play(haptic: .lightSuccess, tier: .low)
        }
        toggleRead()
    }
    
    func markReadAction(appState: AppState, feedback: Set<FeedbackType> = []) -> BasicAction {
        .init(
            id: "markRead\(uid)",
            appearance: .markRead(isOn: shimRead),
            callback: api.canInteract(appState: appState) ? { @MainActor in self.toggleRead(feedback: feedback) } : nil
        )
    }
}
