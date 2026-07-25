//
//  SaveAction.swift
//  Mlem
//
//  Created by Sjmarf on 2025-10-25.
//

import Actions
import MlemMiddleware
import SwiftUI

struct SaveAction: SimpleLabelAction {
    let entity: any InteractableProviding
}

// MARK: - Configurability

extension ActionSeed {
    static let save = ActionSeed("save") { entity in
        switch entity {
        case let entity as any InteractableProviding: SaveAction(entity: entity)
        default: nil
        }
    }
}

// MARK: - Appearance

extension SaveAction {
    static let saveAppearance: ActionAppearance = .init(
        currentStateLabel: .init("Unsaved", icon: .lemmy.saved.representingState(active: false)),
        stateTransitionLabel: .init("Save", icon: .lemmy.addSave),
        color: .themedSave
    )
    static let unsaveAppearance: ActionAppearance = .init(
        currentStateLabel: .init("Saved", icon: .lemmy.saved.representingState(active: true)),
        stateTransitionLabel: .init("Unsave", icon: .lemmy.removeSave),
        color: .themedSave
    )

    static var appearance: ActionAppearance { saveAppearance }

    func createAppearance(environment: EnvironmentValues) -> ActionAppearance {
        guard let saved = entity.saved.value else { return Self.saveAppearance.withVisibility(.hidden) }
        if saved {
            return Self.unsaveAppearance.withVisibility(visibility(environment))
        } else {
            return Self.saveAppearance.withVisibility(visibility(environment))
        }
    }

    private func visibility(_ environment: EnvironmentValues) -> ActionVisiblity {
        guard entity.api.canInteract(appState: environment.appState) else { return .hidden }
        return .enabled
    }
}

// MARK: - Behavior

extension SaveAction {
    @MainActor
    func execute(environment: EnvironmentValues) {
        guard let toggleSaved = entity.toggleSaved else { return }
        toggleSaved([.haptic])
    }
}
