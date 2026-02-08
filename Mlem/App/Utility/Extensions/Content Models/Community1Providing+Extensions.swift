//
//  Community1Providing+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 05/05/2024.
//

import Foundation
import Haptics
import MlemMiddleware
import QuickSwipes

extension Community1Providing {
    private var self2: (any Community2Providing)? { self as? any Community2Providing }
    
    var shouldHideInFeed: Bool { blocked }
    
    // MARK: Operations
    
    func toggleSubscribe(feedback: Set<FeedbackType>) {
        if let self2 {
            if feedback.contains(.haptic) {
                HapticManager.main.play(haptic: .lightSuccess, tier: .low)
            }
            if feedback.contains(.toast) {
                let wasFavorited = self2.favorited
                if self2.subscribed {
                    ToastModel.main.add(
                        .undoable(
                            "Unsubscribed",
                            icon: .lemmy.didUnsubscribe,
                            callback: {
                                if wasFavorited {
                                    self2.updateFavorite(true)
                                } else {
                                    self2.updateSubscribe(true)
                                }
                            },
                            color: .themedAccent
                        )
                    )
                }
            }
            self2.toggleSubscribe()
        } else {
            handleError(MlemError.modelError("No self2 found"), silent: true)
        }
    }
    
    func toggleBlocked(feedback: Set<FeedbackType>) {
        if feedback.contains(.toast) {
            if !blocked {
                ToastModel.main.add(
                    .undoable(
                        "Blocked",
                        icon: .lemmy.block,
                        callback: {
                            self.updateBlocked(false)
                        },
                        color: .themedNegative
                    )
                )
            } else {
                ToastModel.main.add(
                    .undoable(
                        "Unblocked",
                        icon: .lemmy.unblock,
                        callback: {
                            self.updateBlocked(true)
                        },
                        color: .themedPrimary
                    )
                )
            }
        }
        toggleBlocked()
    }
}
