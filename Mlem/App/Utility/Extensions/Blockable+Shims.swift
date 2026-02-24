//
//  Blockable+Shims.swift
//  Mlem
//
//  Created by Eric Andrews on 2026-02-10.
//

import MlemMiddleware

// TODO: Unified Community remove
extension Blockable {
    func shimToggleBlocked(feedback: Set<FeedbackType>, callback: ((Bool) -> Void)? = nil) {
        if feedback.contains(.toast) {
            if !blockedValue {
                ToastModel.main.add(
                    .undoable(
                        "Blocked",
                        icon: .lemmy.block,
                        callback: {
                            self.updateBlocked(false, callback: callback)
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
                            self.updateBlocked(true, callback: callback)
                        },
                        color: .themedPrimary
                    )
                )
            }
        }
        updateBlocked(!blockedValue, callback: callback)
    }
}
