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
        toggleBlocked()
    }
    
    @ActionBuilder
    func menuActions(feedback: Set<FeedbackType> = [.haptic]) -> [any Action] {
        openInstanceAction()
        copyNameAction()
        shareAction()
        blockAction()
    }
    
    func blockAction(feedback: Set<FeedbackType> = [], showConfirmation: Bool = true) -> BasicAction {
        .init(
            id: "block\(uid)",
            isOn: false,
            label: blocked ? "Unblock" : "Block",
            color: Palette.main.negative,
            isDestructive: !blocked,
            confirmationPrompt: (!blocked && showConfirmation) ? "Really block this user?" : nil,
            icon: blocked ? Icons.show : Icons.hide,
            callback: api.willSendToken ? { self.toggleBlocked(feedback: feedback) } : nil
        )
    }
}
