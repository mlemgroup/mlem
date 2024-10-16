//
//  Instance1Providing+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 08/07/2024.
//

import Foundation
import MlemMiddleware

extension InstanceStubProviding {
    private var self1: (any Instance1Providing)? { self as? any Instance1Providing }
    
    func toggleBlocked(feedback: Set<FeedbackType> = []) {
        guard let self = self as? any Instance1Providing else {
            assertionFailure("Don't call this on a stub")
            return
        }
        
        if !self.blocked, feedback.contains(.toast) {
            ToastModel.main.add(
                .undoable(
                    "Blocked",
                    systemImage: Icons.hideFill,
                    callback: {
                        self.updateBlocked(false)
                    },
                    color: Palette.main.negative
                )
            )
        }
        self.toggleBlocked()
    }
    
    func visit() {
        if let account = try? GuestAccount.getGuestAccount(url: actorId) {
            AppState.main.changeAccount(to: account)
            AppState.main.contentViewTab = .feeds
        }
    }
    
    func openLoginSheet() {
        NavigationModel.main.openSheet(.logIn(.instance(self)))
    }
    
    func openSignUpSheet() {
        NavigationModel.main.openSheet(.signUp(self))
    }
    
    var isVisiting: Bool {
        AppState.main.firstApi.host == host && AppState.main.firstApi.token == nil
    }
    
    @ActionBuilder
    func menuActions(
        feedback: Set<FeedbackType> = [.haptic, .toast],
        allowExternalBlocking: Bool = false
    ) -> [any Action] {
        ActionGroup {
            visitAction()
            logInAction()
            signUpAction()
        }
        ActionGroup {
            openInBrowserAction()
            shareAction()
        }
        if !local || (allowExternalBlocking && actorId != AppState.main.firstApi.actorId) {
            ActionGroup {
                blockAction(
                    feedback: feedback,
                    allowExternalBlocking: allowExternalBlocking
                )
            }
        }
    }
    
    func visitAction() -> BasicAction {
        .init(
            id: "visit\(actorId)",
            appearance: .init(
                label: "Visit",
                color: .gray,
                icon: "arrow.right"
            ),
            callback: isVisiting ? nil : visit
        )
    }
    
    func logInAction() -> BasicAction {
        .init(
            id: "logIn\(actorId)",
            appearance: .init(
                label: "Log In",
                color: .gray,
                icon: Icons.logIn
            ),
            callback: openLoginSheet
        )
    }
    
    func signUpAction() -> BasicAction {
        .init(
            id: "signup\(actorId)",
            appearance: .init(
                label: "Sign Up",
                color: .gray,
                icon: Icons.signUp
            ),
            callback: openSignUpSheet
        )
    }
    
    func openInBrowserAction() -> BasicAction {
        .init(
            id: "openInstanceUrl\(actorId)",
            appearance: .init(
                label: "Open in Browser",
                isOn: false,
                color: .gray,
                icon: Icons.browser
            ),
            callback: {
                openRegularLink(url: self.actorId)
            }
        )
    }
    
    /// If `allowExternalBlocking` is `true`, Instances created from guest ApiClients (and InstanceStubs)
    /// will display and update the block status of the instance on the active UserSession. Otherwise, the block
    /// action on those models will be disabled.
    func blockAction(
        feedback: Set<FeedbackType> = [],
        showConfirmation: Bool = true,
        allowExternalBlocking: Bool = false
    ) -> BasicAction {
        let blocked: Bool
        let callback: (() -> Void)?
        if let self = self as? any Instance1Providing, api.token != nil {
            blocked = self.blocked
            callback = api.canInteract ? { self.toggleBlocked(feedback: feedback) } : nil
        } else if allowExternalBlocking, let session = (AppState.main.firstSession as? UserSession) {
            blocked = session.blocks?.contains(self) ?? false
            callback = { session.toggleInstanceBlock(actorId: actorId) }
        } else {
            blocked = false
            callback = nil
        }
        return .init(
            id: "blockInstance\(actorId)",
            appearance: .block(isOn: blocked),
            confirmationPrompt: (!blocked && showConfirmation) ? "Really block this instance?" : nil,
            callback: callback
        )
    }
}
