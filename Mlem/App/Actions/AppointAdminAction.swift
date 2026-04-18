//
//  AppointAdminAction.swift
//  Mlem
//
//  Created by Sjmarf on 2025-10-13.
//

import Actions
import MlemMiddleware
import SwiftUI

struct AppointAdminAction: Actions.Action {
    let entity: Person
}

// MARK: - Configurability

extension ActionSeed {
    static let appointAdmin = ActionSeed("appointAdmin", label: AppointAdminAction.appointLabel) { entity in
        switch entity {
        case let entity as Person:
            AppointAdminAction(entity: entity)
        default:
            nil
        }
    }
}

// MARK: - Appearance

extension AppointAdminAction {
    static let appointLabel: ActionLabel = .init(
        "Appoint Administrator",
        icon: .lemmy.addAdministrator,
        color: .themedPositive
    )

    static let demoteLabel: ActionLabel = .init(
        "Remove Administrator",
        icon: .lemmy.removeAdministrator,
        color: .themedNegative
    )

    func createLabel(environment: EnvironmentValues) -> ActionLabel {
        guard let isAdmin = entity.isAdmin.value else { return Self.demoteLabel.withVisibility(.hidden) }
        let label: ActionLabel

        if isAdmin {
            label = Self.demoteLabel
        } else {
            label = Self.appointLabel
        }

        return label.withVisibility(visibility(environment))
    }

    private func visibility(_ environment: EnvironmentValues) -> ActionVisiblity {
        guard let entityIsAdmin = entity.isAdmin.value else { return .hidden }
        if entity.api.canInteract(appState: environment.appState),
            entity.api.isAdmin,
            !entityIsAdmin,
            entity.api.isHigherAdmin(than: entity),
            entity.apiIsLocal {
            return .enabled
        } else {
            return .hidden
        }
    }
}

// MARK: - Behavior

extension AppointAdminAction {
    func execute(environment: EnvironmentValues) {
        guard let message = self.popupMessage(environment: environment) else {
            assertionFailure()
            return
        }
        environment.popupModel?.showPopup(message: message, [
            .init(title: "Yes", isDestructive: true) {
                confirm(environment: environment)
            }
        ])
    }

    private func popupMessage(environment: EnvironmentValues) -> LocalizedStringResource? {
        guard let isAdmin = self.entity.isAdmin.value else { return nil }
        if isAdmin {
            return "Really remove administrator \(entity.displayName) from \(self.entity.api.host)?"
        } else {
            return "Really appoint \(entity.displayName) as an administrator of \(self.entity.api.host)?"
        }
    }

    private func confirm(environment: EnvironmentValues) {
        guard let instance = entity.api.myInstance,
        let isAdmin = entity.isAdmin.value else {
            assertionFailure()
            return
        }

        instance.addAdmin(personId: self.entity.id, added: !isAdmin)
    }
}
