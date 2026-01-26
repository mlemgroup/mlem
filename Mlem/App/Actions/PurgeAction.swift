//
//  PurgeAction.swift
//  Mlem
//
//  Created by Sjmarf on 2025-10-25.
//

import Actions
import MlemMiddleware
import SwiftUI

struct PurgeAction: Actions.Action {
    enum Relationship { case identity, author }

    let entity: any PurgableProviding
    let relationship: Relationship
}

// MARK: - Configurability

extension ActionSeed {
    static let purge = ActionSeed("purge", label: PurgeAction.createLabel(relationship: .identity)) { entity in
        switch entity {
        case let entity as any PurgableProviding: PurgeAction(entity: entity, relationship: .identity)
        default: nil
        }
    }

    static let purgeCreator = ActionSeed("purgeCreator", label: PurgeAction.createLabel(relationship: .author)) { entity in
        switch entity {
        case let entity as any InteractableProviding:
            if let creator = entity.creator.value {
                PurgeAction(entity: creator, relationship: .author)
            } else {
                nil
            }
        default: nil
        }
    }
}

// MARK: - Appearance

extension PurgeAction {
    static func createLabel(relationship: Relationship) -> ActionLabel {
        .init(
            relationship == .identity ? "Purge" : "Purge User",
            icon: .lemmy.purge,
            color: .themedNegative,
            isDestructive: true
        )
    }
    
    func createLabel(environment: EnvironmentValues) -> ActionLabel {
        return Self.createLabel(relationship: self.relationship).withVisibility(visibility(environment))
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
