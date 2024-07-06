//
//  Person1Providing+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 02/07/2024.
//

import MlemMiddleware

extension Person1Providing {
    func toggleBlocked(feedback: Set<FeedbackType> = []) {
        if !blocked, feedback.contains(.toast) {
                ToastModel.main.add(
                    .undoable(
                        title: "Blocked",
                        systemImage: Icons.hideFill,
                        callback: {
                            self.updateBlocked(false)
                        },
                        color: Palette.main.negative
                    )
                )
            }
        }
        toggleBlocked()
    }
}
