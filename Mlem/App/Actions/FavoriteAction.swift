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
    static let favoriteAppearance: ActionAppearance = .init(
        "Favorite",
        icon: .lemmy.favorite,
        color: .themedFavorite
    )
    static let unfavoriteAppearance: ActionAppearance = .init(
        "Unfavorite",
        icon: .lemmy.unfavorite,
        color: .themedFavorite
    )

    static var appearance: ActionAppearance { favoriteAppearance }

    func createAppearance(environment: EnvironmentValues) -> ActionAppearance {
        if entity.favorited {
            return Self.unfavoriteAppearance.withVisibility(visibility(environment))
        } else {
            return Self.favoriteAppearance.withVisibility(visibility(environment))
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
