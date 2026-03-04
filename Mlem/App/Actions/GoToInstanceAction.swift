//
//  GoToInstanceAction.swift
//  Mlem
//
//  Created by Sjmarf on 2025-10-25.
//

import Actions
import MlemMiddleware
import SwiftUI

struct GoToInstanceAction: SimpleLabelAction {
    let entity: any ActorIdentifiable
}

// MARK: - Configurability

extension ActionSeed {
    static let goToInstance = ActionSeed("goToInstance") { entity in
        switch entity {
        case let entity as any ActorIdentifiable: GoToInstanceAction(entity: entity)
        default: nil
        }
    }
}

// MARK: - Appearance

extension GoToInstanceAction {
    static let label: ActionLabel = .init(
        "Go to Instance",
        icon: .lemmy.instance,
        color: .themedColorfulAccent(1)
    )

    func createLabel(environment: EnvironmentValues) -> ActionLabel {
        .init(
            entity.host,
            icon: .lemmy.instance,
            color: .themedColorfulAccent(1)
        )
    }
}

// MARK: - Behavior

extension GoToInstanceAction {
    @MainActor
    func execute(environment: EnvironmentValues) {
        environment.navigation?.push(.instance(hostOf: self.entity)) 
    }
}
