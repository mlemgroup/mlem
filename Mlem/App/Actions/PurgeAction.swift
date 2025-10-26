//
//  PurgeAction.swift
//  Mlem
//
//  Created by Sjmarf on 2025-10-25.
//

import Actions
import MlemMiddleware
import SwiftUI

struct PurgeAction: ConfigurableAction {
    let entity: any PurgableProviding
}

// MARK: - Configurability

extension ActionSeed {
    static let purge = ActionSeed("purge") { entity in
        switch entity {
        case let entity as any PurgableProviding: PurgeAction(entity: entity)
        default: nil
        }
    }
}

// MARK: - Appearance

extension PurgeAction {
    static let label: ActionLabel = .init("Purge", icon: .lemmy.purge, isDestructive: true)
    
    func createLabel(environment: EnvironmentValues) -> ActionLabel {
        Self.label.withVisibility(visibility(environment))
    }
    
    private func visibility(_ environment: EnvironmentValues) -> ActionVisiblity {
        guard entity.api.canInteract(appState: environment.appState) else { return .hidden }
        
        guard entity.api.supports(.purgeContent, defaultValue: false) else { return .hidden }
        guard entity.api.isAdmin else { return .hidden }

        return .enabled
    }
}

// MARK: - Behavior

extension PurgeAction {
    @MainActor
    func execute(environment: EnvironmentValues) {
        environment.navigation?.openSheet(.purge(entity))
    }
}
