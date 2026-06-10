//
//  ToggleNotificationsAction.swift
//  Mlem
//
//  Created by Sjmarf on 2026-06-10.
//

import Actions
import MlemMiddleware
import SwiftUI

struct ToggleNotificationsAction: SimpleLabelAction {
    let entity: Comment
}

// MARK: - Configurability

extension ActionSeed {
    static let toggleNotifications = ActionSeed("toggleNotifications") { entity in
        switch entity {
        case let entity as Comment: ToggleNotificationsAction(entity: entity)
        default: nil
        }
    }
}

// MARK: - Appearance

extension ToggleNotificationsAction {
    static let enableLabel: ActionLabel = .init(
        "Enable Notifications",
        icon: .lemmy.enableNotifications,
        color: .themedColorfulAccent(4)
    )

    static let disableLabel: ActionLabel = .init(
        "Disable Notifications",
        icon: .lemmy.disableNotifications,
        color: .themedColorfulAccent(4)
    )
    
    static let label: ActionLabel = .init(
        "Toggle Notifications",
        icon: .lemmy.notification,
        color: .themedColorfulAccent(4)
    )

    func createLabel(environment: EnvironmentValues) -> ActionLabel {
        guard let notificationsEnabled = entity.notificationsEnabled.value else {
            return Self.enableLabel.withVisibility(.hidden)
        }
        if notificationsEnabled {
            return Self.disableLabel.withVisibility(visibility(environment))
        } else {
            return Self.enableLabel.withVisibility(visibility(environment))
        }
    }

    private func visibility(_ environment: EnvironmentValues) -> ActionVisiblity {
        guard entity.api.canInteract(appState: environment.appState) else { return .hidden }
        return .enabled
    }
}

// MARK: - Behavior

extension ToggleNotificationsAction {

    @MainActor
    func execute(environment: EnvironmentValues) {
        if let currentValue = entity.notificationsEnabled.value {
            entity.updateNotificationsEnabled(!currentValue)
        }
    }
}
