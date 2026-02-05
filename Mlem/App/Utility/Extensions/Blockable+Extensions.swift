//
//  Blockable+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2026-02-03.
//

import MlemMiddleware

extension Blockable {
    func toggleBlocked(feedback: Set<FeedbackType>, callback: ((Bool) -> Void)? = nil) {
        if feedback.contains(.toast) {
            if !blocked {
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
        updateBlocked(!blocked, callback: callback)
    }
}
