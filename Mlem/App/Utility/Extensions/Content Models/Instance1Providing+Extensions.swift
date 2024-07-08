//
//  Instance1Providing+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 08/07/2024.
//

import MlemMiddleware

extension Instance1Providing {
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
    
    func menuActions(feedback: Set<FeedbackType> = [.haptic, .toast]) -> ActionGroup {
        ActionGroup(
            children: [
                blockAction(feedback: feedback)
            ]
        )
    }
    
    func blockAction(feedback: Set<FeedbackType> = [], showConfirmation: Bool = true) -> BasicAction {
        .init(
            id: "blockInstance\(actorId.absoluteString)",
            isOn: false,
            label: "Block",
            color: Palette.main.negative,
            isDestructive: true,
            confirmationPrompt: showConfirmation ? "Really block this instance?" : nil,
            icon: Icons.hide,
            callback: api.willSendToken ? { self.toggleBlocked(feedback: feedback) } : nil
        )
    }
}
