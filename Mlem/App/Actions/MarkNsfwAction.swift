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
    let entity: UnifiedPostModel
}

// MARK: - Configurability

extension ActionSeed {
    static let markNsfw = ActionSeed("markNsfw") { entity in
        switch entity {
        case let entity as UnifiedPostModel: MarkNsfwAction(entity: entity)
        default: nil
        }
    }
}

// MARK: - Appearance

extension MarkNsfwAction {
    static let addLabel: ActionLabel = .init(
        "Add NSFW Tag",
        icon: .settings.blurNsfw,
        color: .themedNegative
    )

    static let removeLabel: ActionLabel = .init(
        "Remove Nsfw Tag",
        icon: .settings.blurNsfw,
        color: .themedNegative
    )
    
    static var label: ActionLabel { addLabel }

    func createLabel(environment: EnvironmentValues) -> ActionLabel {
        if entity.nsfw {
            Self.removeLabel.withVisibility(visibility(environment))
        } else {
            Self.addLabel.withVisibility(visibility(environment))
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
