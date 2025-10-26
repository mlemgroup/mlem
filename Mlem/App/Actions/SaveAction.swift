//
//  SaveAction.swift
//  Mlem
//
//  Created by Sjmarf on 2025-10-25.
//

import Actions
import MlemMiddleware
import SwiftUI

struct SaveAction: ConfigurableAction {
    let entity: any Interactable2Providing
}

// MARK: - Configurability

extension ActionSeed {
    static let save = ActionSeed("save") { entity in
        switch entity {
        case let entity as any Interactable2Providing: SaveAction(entity: entity)
        default: nil
        }
    }
}

// MARK: - Appearance

extension SaveAction {
    static let saveLabel: ActionLabel = .init("Save", icon: .lemmy.saved.representingState(active: false))
    static let unsaveLabel: ActionLabel = .init("Saved", icon: .lemmy.saved.representingState(active: true))
    
    static var label: ActionLabel { saveLabel }

    func createLabel(environment: EnvironmentValues) -> ActionLabel {
        if entity.saved {
            Self.unsaveLabel.withVisibility(visibility(environment))
        } else {
            Self.saveLabel.withVisibility(visibility(environment))
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
        entity.toggleSaved()
        environment.hapticManager.play(haptic: .success, tier: .low)
    }
}
