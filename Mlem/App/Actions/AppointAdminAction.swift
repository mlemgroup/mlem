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
    let entity: any Person1Providing
}

// MARK: - Configurability

extension ActionSeed {
    static let appointAdmin = ActionSeed("appointAdmin", label: AppointAdminAction.appointLabel) { entity in
        switch entity {
        case let entity as any Person1Providing:
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
        let label: ActionLabel

        if self.entity.isAdmin_ ?? false {
            label = Self.demoteLabel
        } else {
            label = Self.appointLabel
        }

        return label.withVisibility(visibility(environment))
    }

    private func visibility(_ environment: EnvironmentValues) -> ActionVisiblity {
        if entity.api.canInteract(appState: environment.appState),
            entity.api.isAdmin,
            !(entity.isAdmin_ ?? false),
            entity.api.isHigherAdmin(than: entity),
            entity.apiIsLocal {
            .enabled
        } else {
            .hidden
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
        if self.entity.isAdmin_ ?? false {
            return "Really remove administrator \(entity.displayName) from \(self.entity.api.host)?"
        } else {
            return "Really appoint \(entity.displayName) as an administrator of \(self.entity.api.host)?"
        }
    }

    private func confirm(environment: EnvironmentValues) {
        guard let instance = entity.api.myInstance else {
            assertionFailure()
            return
        }

        Task {
            do {
                try await instance.addAdmin(self.entity, added: !(self.entity.isAdmin_ ?? false))
            } catch {
                handleError(error)
            }
        }
    }
}
