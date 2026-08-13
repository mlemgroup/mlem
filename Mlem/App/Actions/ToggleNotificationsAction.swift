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
    static let enableAppearance: ActionAppearance = .init(
        currentStateLabel: .init("Notifications Disabled", icon: .lemmy.notification.representingState(active: false)),
        stateTransitionLabel: .init("Enable Notifications", icon: .lemmy.enableNotifications),
        color: .themedColorfulAccent(4)
    )

    static let disableAppearance: ActionAppearance = .init(
        currentStateLabel: .init("Notifications Enabled", icon: .lemmy.notification.representingState(active: true)),
        stateTransitionLabel: .init("Disable Notifications", icon: .lemmy.disableNotifications),
        color: .themedColorfulAccent(4),
        prominent: true
    )

    static let appearance: ActionAppearance = .init(
        "Toggle Notifications",
        icon: .lemmy.notification,
        color: .themedColorfulAccent(4)
    )

    func createAppearance(environment: EnvironmentValues) -> ActionAppearance {
        guard let notificationsEnabled = entity.notificationsEnabled.value else {
            return Self.enableAppearance.withVisibility(.hidden)
        }
        if notificationsEnabled {
            return Self.disableAppearance.withVisibility(visibility(environment))
        } else {
            return Self.enableAppearance.withVisibility(visibility(environment))
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

        environment.hapticManager.play(haptic: .lightSuccess, tier: .low)
        entity.updateNotificationsEnabled(newValue)

        let toast: ToastType

        if newValue {
            toast = .basic("Notifications Enabled", icon: .lemmy.enableNotifications)
        } else {
            toast = .basic("Notifications Disabled", icon: .lemmy.disableNotifications)
        }

        environment.toastModel?.add(toast)
    }
}
