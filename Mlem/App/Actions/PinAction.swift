//
//  PinAction.swift
//  Mlem
//
//  Created by Sjmarf on 2025-12-23.
//

import Actions
import MlemMiddleware
import SwiftUI

struct PinAction: SimpleLabelAction {
    let entity: any Post2Providing
}

// MARK: - Configurability

extension ActionSeed {
    static let pin = ActionSeed("pin") { entity in
        switch entity {
        case let entity as any Post2Providing: PinAction(entity: entity)
        default: nil
        }
    }
}

// MARK: - Appearance

extension PinAction {
    static let pinLabel: ActionLabel = .init("Pin", icon: .lemmy.addPin)
    static let unpinLabel: ActionLabel = .init("Unpin", icon: .lemmy.removePin)

    static let pinDetailsLabel: ActionLabel = .init("Pin...", icon: .lemmy.addPin)
    
    static var label: ActionLabel { pinLabel }

    func createLabel(environment: EnvironmentValues) -> ActionLabel {
        let label: ActionLabel = if entity.api.isAdmin {
            switch (entity.pinnedInstance, entity.pinnedCommunity) {
            case (true, true):
                Self.unpinLabel
            case (true, false), (false, true):
                Self.pinDetailsLabel
            case (false, false):
                Self.pinLabel
            }
        } else {
            if entity.pinnedCommunity {
                Self.unpinLabel
            } else {
                Self.pinLabel
            }
        }

        return label.withVisibility(visibility(environment))
    }

    private func visibility(_ environment: EnvironmentValues) -> ActionVisiblity {
        if entity.api.canInteract(appState: environment.appState), entity.canModerate {
            .enabled
        } else {
            .hidden
        }
    }
}

// MARK: - Behavior

extension PinAction {
    @MainActor
    func execute(environment: EnvironmentValues) {
        if entity.api.isAdmin {
            executeAsAdmin(environment: environment)
        } else {
            executeAsModerator(environment: environment)
        }
    }

    @MainActor
    func executeAsModerator(environment: EnvironmentValues) {
        environment.popupModel?.showPopup(
            message: entity.pinnedCommunity ? "Really unpin this post?" : "Really pin this post?",
            [
            .init(title: "Yes", isDestructive: false) {
                entity.togglePinnedCommunity()
            }
        ])
    }

    @MainActor
    func executeAsAdmin(environment: EnvironmentValues) {
        environment.popupModel?.showPopup(
            message: "Choose target...",
            [
                .init(title: entity.pinnedCommunity ? "Unpin from community" : "Pin to community") {
                    entity.togglePinnedCommunity()
                },
                .init(title: entity.pinnedInstance ? "Unpin from instance" : "Pin to instance") {
                    entity.togglePinnedInstance()
                }
            ]
        )
    }
}
