//
//  HideAction.swift
//  Mlem
//
//  Created by Sjmarf on 2025-12-23.
//

import Actions
import MlemMiddleware
import SwiftUI

struct HideAction: SimpleLabelAction {
    let entity: UnifiedPostModel
}

// MARK: - Configurability

extension ActionSeed {
    static let hide = ActionSeed("hide") { entity in
        switch entity {
        case let entity as UnifiedPostModel: HideAction(entity: entity)
        default: nil
        }
    }
}

// MARK: - Appearance

extension HideAction {
    static let hideLabel: ActionLabel = .init("Hide", icon: .general.hide)
    static let showLabel: ActionLabel = .init("Show", icon: .general.show)
    
    static var label: ActionLabel { hideLabel }

    func createLabel(environment: EnvironmentValues) -> ActionLabel {
        guard let hidden = entity.hidden.value else { return Self.showLabel.withVisibility(.hidden) }
        if hidden {
            return Self.showLabel.withVisibility(visibility(environment))
        } else {
            return Self.hideLabel.withVisibility(visibility(environment))
        }
    }

    private func visibility(_ environment: EnvironmentValues) -> ActionVisiblity {
        if entity.api.canInteract(appState: environment.appState),
            entity.api.supports(.hidePosts, defaultValue: false) {
            .enabled
        } else {
            .hidden
        }
    }
}

// MARK: - Behavior

extension HideAction {
    @MainActor
    func execute(environment: EnvironmentValues) {
        guard let hidden = entity.hidden.value, let toggleHidden = entity.toggleHidden else { return }
        toggleHidden([])
        environment.hapticManager.play(haptic: .lightSuccess, tier: .low)
        if !hidden {
            environment.toastModel?.add(
                .undoable(
                    "Hidden",
                    icon: .general.hide,
                    callback: {
                        entity.updateHidden(false)
                    }
                )
            )
        } else {
            environment.toastModel?.add(.success("Shown"))
        }
    }
}
