//
//  Report+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 2024-12-16.
//

import Haptics
import MlemMiddleware

extension Report {
    func toggleResolved(feedback: Set<FeedbackType>) {
        if feedback.contains(.haptic) {
            HapticManager.main.play(haptic: .success, tier: .low)
        }
        toggleResolved()
    }
    
}
