//
//  RemoveAction.swift
//  Mlem
//
//  Created by Sjmarf on 2025-10-25.
//

import Actions
import MlemMiddleware
import SwiftUI

struct RemoveAction: SimpleLabelAction {
    let entity: any RemovableProviding
}

// MARK: - Configurability

extension ActionSeed {
    static let remove = ActionSeed("remove") { entity in
        switch entity {
        case let entity as any RemovableProviding: RemoveAction(entity: entity)
        default: nil
        }
    }
}

// MARK: - Appearance

extension RemoveAction {
    static let removeAppearance: ActionAppearance = .init(
        currentStateLabel: .init("Unremoved", icon: .lemmy.removed.representingState(active: false)),
        stateTransitionLabel: .init("Remove", icon: .lemmy.remove),
        color: .themedNegative,
        isDestructive: true
    )
    static let restoreAppearance: ActionAppearance = .init(
        currentStateLabel: .init("Removed", icon: .lemmy.removed.representingState(active: true)),
        stateTransitionLabel: .init("Restore", icon: .lemmy.restore),
        color: .themedPositive
    )

    static var appearance: ActionAppearance { removeAppearance }

    func createAppearance(environment: EnvironmentValues) -> ActionAppearance {
        if entity.removed {
            Self.restoreAppearance.withVisibility(visibility(environment))
        } else {
            Self.removeAppearance.withVisibility(visibility(environment))
        }
    }
    
    private func visibility(_ environment: EnvironmentValues) -> ActionVisiblity {
        guard entity.api.canInteract(appState: environment.appState) else { return .hidden }
        
        guard let myPerson = entity.api.myPerson else { return .hidden }
        guard entity.canModerate else { return .hidden }

        if entity is Community {
            guard entity.api.isAdmin else { return .hidden }
        }

        if let entity = entity as? any OwnershipProviding {
            guard !entity.isOwnContent(myPersonId: myPerson.id) else { return .hidden }
        }

        return .enabled
    }
}

// MARK: - Behavior

extension RemoveAction {
    @MainActor
    func execute(environment: EnvironmentValues) {
        environment.navigation?.openSheet(.remove(entity))
    }
}
