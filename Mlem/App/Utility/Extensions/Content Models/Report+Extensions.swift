//
//  Report+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 2024-12-16.
//

import MlemMiddleware

extension Report {
    @ActionBuilder
    func menuActions(
        feedback: Set<FeedbackType> = [.haptic]
    ) -> [any Action] {
        resolveAction(feedback: feedback)
    }
    
    func resolveAction(feedback: Set<FeedbackType> = []) -> BasicAction {
        .init(
            id: "resolve\(cacheId)",
            appearance: .init(
                label: "Resolve",
                color: Palette.main.positive,
                icon: Icons.successCircle,
                swipeIcon2: Icons.successCircleFill
            ),
            callback: api.canInteract ? {} : nil
        )
    }
}
