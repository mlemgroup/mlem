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
    let entity: any Post2Providing
}

// MARK: - Configurability

extension ActionSeed {
    static let lock = ActionSeed("lock") { entity in
        switch entity {
        case let entity as any Post2Providing: LockAction(entity: entity)
        default: nil
        }
    }
}

// MARK: - Appearance

extension LockAction {
    static let lockLabel: ActionLabel = .init(
        "Lock",
        icon: .lemmy.addLock,
        color: .themedLockAccent
    )

    static let unlockLabel: ActionLabel = .init(
        "Unlock",
        icon: .lemmy.removeLock,
        color: .themedLockAccent
    )
    
    static var label: ActionLabel { lockLabel }

    func createLabel(environment: EnvironmentValues) -> ActionLabel {
        if entity.locked {
            Self.unlockLabel.withVisibility(visibility(environment))
        } else {
            Self.lockLabel.withVisibility(visibility(environment))
        }
    }

    private func visibility(_ environment: EnvironmentValues) -> ActionVisiblity {
        if entity.api.canInteract(appState: environment.appState),
           entity.canModerate,
           Settings.get(\.menus_allModActions) || environment.feedContext == .post {
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
        environment.hapticManager.play(haptic: .lightSuccess, tier: .low)
        environment.popupModel?.showPopup(
            message: entity.locked ? "Really unlock this post?" : "Really lock this post?",
            [
            .init(title: "Yes", isDestructive: true) {
                environment.hapticManager.play(haptic: .lightSuccess, tier: .low)
                entity.toggleLocked()
            }
        ])
    }
}
