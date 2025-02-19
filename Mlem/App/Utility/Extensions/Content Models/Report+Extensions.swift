//
//  Report+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 2024-12-16.
//

import MlemMiddleware

extension Report {
    func toggleResolved(feedback: Set<FeedbackType>) {
        if feedback.contains(.haptic) {
            HapticManager.main.play(haptic: .success, priority: .low)
        }
        toggleResolved()
    }
    
    @ActionBuilder
    func menuActions(
        feedback: Set<FeedbackType> = [.haptic]
    ) -> [any Action] {
        resolveAction(feedback: feedback)
    }
    
    func resolveAction(feedback: Set<FeedbackType> = []) -> BasicAction {
        .init(
            id: "resolve\(cacheId)",
            appearance: .resolve(isOn: resolved),
            callback: api.canInteract ? { @MainActor in self.toggleResolved(feedback: feedback) } : nil
        )
    }
}
