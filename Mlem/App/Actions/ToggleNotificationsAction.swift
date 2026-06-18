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
    let entity: any NotificationToggleProviding
}

// MARK: - Configurability

extension ActionSeed {
    static let toggleNotifications = ActionSeed("toggleNotifications") { entity in
        switch entity {
        case let entity as any NotificationToggleProviding: ToggleNotificationsAction(entity: entity)
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
        if entity.api.canInteract(appState: environment.appState),
            entity.api.supports(.toggleNotifications, defaultValue: false) {
            .enabled
        } else {
            .hidden
        }
    }
}

// MARK: - Behavior

extension ToggleNotificationsAction {

    @MainActor
    func execute(environment: EnvironmentValues) {
        guard let currentValue = entity.notificationsEnabled.value else { return }
        let newValue = !currentValue

        entity.updateNotificationsEnabled(newValue)
        environment.hapticManager.play(haptic: .lightSuccess, tier: .low)

        let toast: ToastType

        if newValue {
            toast = .basic("Notifications Enabled", icon: .lemmy.enableNotifications)
        } else {
            toast = .basic("Notifications Disabled", icon: .lemmy.disableNotifications)
        }

        environment.toastModel?.add(toast)
    }
}
