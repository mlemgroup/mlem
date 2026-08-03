//
//  LockAction.swift
//  Mlem
//
//  Created by Sjmarf on 2025-12-23.
//

import Actions
import MlemMiddleware
import SwiftUI

struct LockAction: SimpleLabelAction {
    let entity: Post
}

// MARK: - Configurability

extension ActionSeed {
    static let lock = ActionSeed("lock") { entity in
        switch entity {
        case let entity as Post: LockAction(entity: entity)
        default: nil
        }
    }
}

// MARK: - Appearance

extension LockAction {
    static let lockAppearance: ActionAppearance = .init(
        currentStateLabel: .init("Unlocked", icon: .lemmy.locked.representingState(active: false)),
        stateTransitionLabel: .init("Lock", icon: .lemmy.addLock),
        color: .themedLockAccent
    )

    static let unlockAppearance: ActionAppearance = .init(
        currentStateLabel: .init("Locked", icon: .lemmy.locked.representingState(active: true)),
        stateTransitionLabel: .init("Unlock", icon: .lemmy.removeLock),
        color: .themedLockAccent,
        prominent: true
    )

    static var appearance: ActionAppearance { lockAppearance }

    func createAppearance(environment: EnvironmentValues) -> ActionAppearance {
        if entity.locked {
            Self.unlockAppearance.withVisibility(visibility(environment))
        } else {
            Self.lockAppearance.withVisibility(visibility(environment))
        }
    }

    private func visibility(_ environment: EnvironmentValues) -> ActionVisiblity {
        if entity.api.canInteract(appState: environment.appState), entity.canModerate {
            return .enabled
        } else {
            return .hidden
        }
    }
}

// MARK: - Behavior

extension LockAction {
    @MainActor
    func execute(environment: EnvironmentValues) {
        environment.popupModel?.showPopup(
            message: entity.locked ? "Really unlock this post?" : "Really lock this post?",
            [
            .init(title: "Yes", isDestructive: true) {
                let shouldLock = !entity.locked
                entity.toggleLocked([]) { status in
                    self.handleResult(
                        status: status,
                        shouldLock: shouldLock,
                        environment: environment
                    )
                }
            }
        ])
    }

    @MainActor
    func handleResult(
        status: UpdateStatus,
        shouldLock: Bool,
        environment: EnvironmentValues
    ) {
        switch status {
        case .success:
            environment.hapticManager.play(haptic: .lightSuccess, tier: .low)
        case .failure: 
            environment.toastModel?.add(
                .failure(shouldLock ? "Failed to lock post" : "Failed to unlock post")
            )
        }
    }
}
