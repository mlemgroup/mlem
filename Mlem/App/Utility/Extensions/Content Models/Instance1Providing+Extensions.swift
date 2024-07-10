//
//  Instance1Providing+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 08/07/2024.
//

import Foundation
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
    
    @ActionBuilder
    func menuActions(
        feedback: Set<FeedbackType> = [.haptic, .toast],
        externalBlockStatus: Bool = false,
        externalBlockCallback: (() -> Void)? = nil
    ) -> [any Action] {
        ActionGroup {
            openInBrowserAction()
            shareAction()
        }
        if !local || externalBlockCallback != nil {
            ActionGroup {
                blockAction(
                    feedback: feedback,
                    externalBlockStatus: externalBlockStatus,
                    externalBlockCallback: externalBlockCallback
                )
            }
        }
    }
    
    func openInBrowserAction() -> BasicAction {
        .init(
            id: "openInstanceUrl\(uid)",
            isOn: false,
            label: "Open in Browser",
            color: .gray,
            icon: Icons.browser,
            callback: {
                openRegularLink(url: self.actorId)
            }
        )
    }
    
    func blockAction(
        feedback: Set<FeedbackType> = [],
        showConfirmation: Bool = true,
        externalBlockStatus: Bool = false,
        externalBlockCallback: (() -> Void)? = nil
    ) -> BasicAction {
        let blocked = (api.token == nil ? externalBlockStatus : blocked)
        return .init(
            id: "blockInstance\(uid)",
            isOn: false,
            label: blocked ? "Unblock" : "Block",
            color: Palette.main.negative,
            isDestructive: !blocked,
            confirmationPrompt: (!blocked && showConfirmation) ? "Really block this instance?" : nil,
            icon: blocked ? Icons.show : Icons.hide,
            callback: api.willSendToken ? { self.toggleBlocked(feedback: feedback) } : externalBlockCallback
        )
    }
}
