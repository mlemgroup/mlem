//
//  FavoriteAction.swift
//  Mlem
//
//  Created by Sjmarf on 2026-02-08.
//

import Actions
import MlemMiddleware
import SwiftUI

struct FavoriteAction: SimpleLabelAction {
    let entity: Community
}

// MARK: - Configurability

extension ActionSeed {
    static let favorite = ActionSeed("favorite") { entity in
        switch entity {
        case let entity as Community: FavoriteAction(entity: entity)
        default: nil
        }
    }
}

// MARK: - Appearance

extension FavoriteAction {
    static let favoriteLabel: ActionLabel = .init(
        "Favorite",
        icon: .lemmy.favorite,
        color: .themedFavorite
    )
    static let unfavoriteLabel: ActionLabel = .init(
        "Unfavorite",
        icon: .lemmy.unfavorite,
        color: .themedFavorite
    )
    
    static var label: ActionLabel { favoriteLabel }

    func createLabel(environment: EnvironmentValues) -> ActionLabel {
        if entity.favorited {
            return Self.unfavoriteLabel.withVisibility(visibility(environment))
        } else {
            return Self.favoriteLabel.withVisibility(visibility(environment))
        }
    }

    private func visibility(_ environment: EnvironmentValues) -> ActionVisiblity {
        guard entity.api.canInteract(appState: environment.appState),
              entity.updateFavorite != nil else { return .hidden }
        return .enabled
    }
}

// MARK: - Behavior

extension FavoriteAction {
    @MainActor
    func execute(environment: EnvironmentValues) {
        guard let updateFavorite = entity.updateFavorite else { return }
        environment.hapticManager.play(haptic: .lightSuccess, tier: .low)
        if entity.favorited {
            environment.toastModel?.add(
                .undoable(
                    "Unfavorited",
                    icon: .lemmy.unfavorite,
                    callback: {
                        updateFavorite(true)
                    },
                    color: .themedFavorite
                )
            )
        } else {
            environment.toastModel?.add(
                .basic("Favorited", icon: .lemmy.favorite, color: .themedFavorite)
            )
        }
        updateFavorite(!entity.favorited)
    }
}
