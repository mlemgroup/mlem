//
//  AppointModeratorAction.swift
//  Mlem
//
//  Created by Sjmarf on 2025-10-13.
//

import Actions
import MlemMiddleware
import SwiftUI

struct AppointModeratorAction: Actions.Action {
    let entity: Person
}

// MARK: - Configurability

extension ActionSeed {
    static let appointModerator = ActionSeed("appointModerator", label: AppointModeratorAction.appointLabel) { entity in
        switch entity {
        case let entity as Person:
            AppointModeratorAction(entity: entity)
        default:
            nil
        }
    }
}

// MARK: - Appearance

extension AppointModeratorAction {
    static let appointLabel: ActionLabel = .init(
        "Appoint Moderator",
        icon: .lemmy.addModerator,
        color: .themedPositive
    )

    static let demoteLabel: ActionLabel = .init(
        "Remove Moderator",
        icon: .lemmy.removeModerator,
        color: .themedNegative
    )

    func createLabel(environment: EnvironmentValues) -> ActionLabel {
        let label: ActionLabel

        if isModerator(environment: environment) ?? false {
            label = Self.demoteLabel
        } else {
            label = Self.appointLabel
        }

        return label.withVisibility(visibility(environment))
    }

    private func visibility(_ environment: EnvironmentValues) -> ActionVisiblity {
        if let communityModerators = environment.communityContext?.moderators.value,
            let myPerson = entity.api.myPerson,
            entity.api.canInteract(appState: environment.appState),
            myPerson.canModerate(entity, communityModerators: communityModerators) {
            .enabled
        } else {
            .hidden
        }
    }
}

// MARK: - Behavior

extension AppointModeratorAction {
    func isModerator(environment: EnvironmentValues) -> Bool? {
        if let communityModerators = environment.communityContext?.moderators.value {
            communityModerators.contains(where: { $0.id == entity.id })
        } else {
            nil
        }
    }

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
        guard let community = environment.communityContext else { return nil }

        if self.isModerator(environment: environment) ?? false {
            return "Really remove moderator \(entity.displayName) from \(community.displayName)?"
        } else {
            return "Really appoint \(entity.displayName) as a moderator of \(community.displayName)?"
        }
    }

    private func confirm(environment: EnvironmentValues) {
        guard let isModerator = self.isModerator(environment: environment) else {
            assertionFailure()
            return
        }
        Task {
            do {
                try await environment.communityContext?.addModerator(self.entity, added: !isModerator)
            } catch {
                handleError(error)
            }
        }
    }
}
