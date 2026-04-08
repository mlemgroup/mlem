//
//  Blockable+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2026-02-10.
//

import MlemMiddleware

extension Blockable {
    var toggleBlocked: ((Set<FeedbackType>, ((Bool) -> Void)?) -> Void)? {
        if let updateBlocked = self.updateBlocked {
            return { toggleBlocked(updateBlocked: updateBlocked, feedback: $0, callback: $1) }
        }
        return nil
    }
    
    private func toggleBlocked(
        updateBlocked: @escaping (Bool, ((Bool) -> Void)?) -> Void,
        feedback: Set<FeedbackType>,
        callback: ((Bool) -> Void)? = nil) {
            if feedback.contains(.toast) {
                if !blockedProviding.realizedValue {
                    ToastModel.main.add(
                        .undoable(
                            "Blocked",
                            icon: .lemmy.block,
                            callback: {
                                updateBlocked(false, callback)
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
                                updateBlocked(true, callback)
                            },
                            color: .themedPrimary
                        )
                    )
                }
            }
            updateBlocked(!blockedProviding.realizedValue, callback)
        }
}
