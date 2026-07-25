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
    let entity: Post
}

// MARK: - Configurability

extension ActionSeed {
    static let hide = ActionSeed("hide") { entity in
        switch entity {
        case let entity as Post: HideAction(entity: entity)
        default: nil
        }
    }
}

// MARK: - Appearance

extension HideAction {
    static let hideAppearance: ActionAppearance = .init(
        currentStateLabel: .init("Shown", icon: .general.hidden.representingState(active: false)),
        stateTransitionLabel: .init("Hide", icon: .general.hide),
        color: .themedColorfulAccent(4)
    )

    static let showAppearance: ActionAppearance = .init(
        currentStateLabel: .init("Hidden", icon: .general.hidden.representingState(active: true)),
        stateTransitionLabel: .init("Show", icon: .general.show),
        color: .themedColorfulAccent(4)
    )

    static var appearance: ActionAppearance { hideAppearance }

    func createAppearance(environment: EnvironmentValues) -> ActionAppearance {
        guard let hidden = entity.hidden.value else { return Self.showAppearance.withVisibility(.hidden) }
        if hidden {
            return Self.showAppearance.withVisibility(visibility(environment))
        } else {
            return Self.hideAppearance.withVisibility(visibility(environment))
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
