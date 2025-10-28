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
    let useVerboseLabel: Bool
}

// MARK: - Configurability

extension ActionSeed {
    static let purge = ActionSeed("purge") { entity in
        switch entity {
        case let entity as any PurgableProviding: PurgeAction(entity: entity, useVerboseLabel: false)
        default: nil
        }
    }

    static let purgeCreator = ActionSeed("purgeCreator") { entity in
        switch entity {
        case let entity as any Interactable2Providing: PurgeAction(entity: entity.creator, useVerboseLabel: true)
        default: nil
        }
    }
}

// MARK: - Appearance

extension PurgeAction {
    static let label: ActionLabel = .init("Purge", icon: .lemmy.purge, isDestructive: true)
    static let verboseLabel: ActionLabel = .init("Purge User", icon: .lemmy.purge, isDestructive: true)
    
    func createLabel(environment: EnvironmentValues) -> ActionLabel {
        if useVerboseLabel {
            assert(entity is any Person1Providing)
            return Self.verboseLabel.withVisibility(visibility(environment))
        } else {
            return Self.label.withVisibility(visibility(environment))
        }
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
