//
//  MarkNsfwAction.swift
//  Mlem
//
//  Created by Sjmarf on 2025-12-23.
//

import Actions
import MlemMiddleware
import SwiftUI

struct MarkNsfwAction: SimpleLabelAction {
    let entity: Post
}

// MARK: - Configurability

extension ActionSeed {
    static let markNsfw = ActionSeed("markNsfw") { entity in
        switch entity {
        case let entity as Post: MarkNsfwAction(entity: entity)
        default: nil
        }
    }
}

// MARK: - Appearance

extension MarkNsfwAction {
    static let addAppearance: ActionAppearance = .init(
        "Add NSFW Tag",
        icon: .settings.blurNsfw,
        color: .themedNegative
    )

    static let removeAppearance: ActionAppearance = .init(
        "Remove NSFW Tag",
        icon: .settings.blurNsfw,
        color: .themedNegative
    )

    static var appearance: ActionAppearance { addAppearance }

    func createAppearance(environment: EnvironmentValues) -> ActionAppearance {
        if entity.nsfw {
            Self.removeAppearance.withVisibility(visibility(environment))
        } else {
            Self.addAppearance.withVisibility(visibility(environment))
        }
    }

    private func visibility(_ environment: EnvironmentValues) -> ActionVisiblity {
        if entity.api.canInteract(appState: environment.appState),
           entity.canModerate,
           let community = entity.community.value,
           community.apiIsLocal, // Setting NSFW doesn't work on non-local communities at the time of writing
           entity.api.supports(.moderatorSetNsfw, defaultValue: false) {
            return .enabled
        } else {
            return .hidden
        }
    }
}

// MARK: - Behavior

extension MarkNsfwAction {
    @MainActor
    func execute(environment: EnvironmentValues) {
        environment.popupModel?.showPopup(
            message: entity.nsfw ? "Really remove NSFW tag?" : "Really add NSFW tag?",
            [
            .init(title: "Yes", isDestructive: true) {
                entity.toggleNsfw { status in
                    switch status {
                    case .success:
                        environment.hapticManager.play(haptic: .lightSuccess, tier: .low)
                    case .failure: 
                        environment.toastModel?.add(.failure("Failed to set NSFW status"))
                    }
                }
            }
        ])
    }
}
