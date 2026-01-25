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
    let entity: InteractableProviding
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
    static let saveLabel: ActionLabel = .init(
        "Save",
        icon: .lemmy.saved.representingState(active: false),
        color: .themedSave
    )
    static let unsaveLabel: ActionLabel = .init(
        "Saved",
        icon: .lemmy.saved.representingState(active: true),
        color: .themedSave
    )
    
    static var label: ActionLabel { saveLabel }

    func createLabel(environment: EnvironmentValues) -> ActionLabel {
        guard let saved = entity.saved.value else { return Self.saveLabel.withVisibility(.hidden) }
        if saved {
            return Self.unsaveLabel.withVisibility(visibility(environment))
        } else {
            return Self.saveLabel.withVisibility(visibility(environment))
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
