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
    
    func visit() {
        let account = GuestAccount.getGuestAccount(url: actorId)
        AppState.main.changeAccount(to: account)
        AppState.main.contentViewTab = .feeds
    }
    
    var isVisiting: Bool {
        AppState.main.firstApi.host == host && AppState.main.firstApi.token == nil
    }
    
    @ActionBuilder
    func menuActions(
        feedback: Set<FeedbackType> = [.haptic, .toast],
        externalBlockStatus: Bool = false,
        externalBlockCallback: (() -> Void)? = nil
    ) -> [any Action] {
        ActionGroup {
            visitAction()
        }
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
    
    func visitAction() -> BasicAction {
        .init(
            id: "visit\(uid)",
            isOn: false,
            label: "Visit",
            color: .gray,
            icon: "arrow.right",
            callback: isVisiting ? nil : visit
        )
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
