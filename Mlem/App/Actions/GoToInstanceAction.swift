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
    static let appearance: ActionAppearance = .init(
        "Go to Instance",
        icon: .lemmy.instance,
        color: .themedInstanceAccent
    )

    func createAppearance(environment: EnvironmentValues) -> ActionAppearance {
        var appearance = Self.appearance
        appearance.title = entity.host
        return appearance
    }
}

// MARK: - Behavior

extension GoToInstanceAction {
    @MainActor
    func execute(environment: EnvironmentValues) {
        environment.navigation?.push(.hostInstance(of: self.entity))
    }
}
