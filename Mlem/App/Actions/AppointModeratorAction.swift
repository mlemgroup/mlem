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
    let entity: Person1Providing
}

// MARK: - Configurability

extension ActionSeed {
    static let appointModerator = ActionSeed("appointModerator", label: AppointModeratorAction.appointLabel) { entity in
        switch entity {
        case let entity as any Person1Providing:
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
        guard let community3 = environment.communityContext as? any Community3Providing else { return .hidden }
        guard let myPerson = entity.api.myPerson else { return .hidden }
        guard entity.api.canInteract(appState: environment.appState) else { return .hidden }
        guard myPerson.canModerate(entity, in: community3) else { return .hidden }
        return entity.id == myPerson.id ? .hidden : .enabled
    }
}

// MARK: - Behavior

extension AppointModeratorAction {
    func isModerator(environment: EnvironmentValues) -> Bool? {
        if let community3 = environment.communityContext as? any Community3Providing {
            community3.moderators.contains(where: { $0.id == entity.id })
        } else {
            nil
        }
    }

    func execute(environment: EnvironmentValues) {
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
