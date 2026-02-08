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
    let entity: any Community1Providing
}

// MARK: - Configurability

extension ActionSeed {
    static let favorite = ActionSeed("favorite") { entity in
        switch entity {
        case let entity as any Community1Providing: FavoriteAction(entity: entity)
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
        guard let subscribed = entity.favorited_  else {
            return Self.favoriteLabel.withVisibility(.hidden)
        }
        if subscribed {
            return Self.unfavoriteLabel.withVisibility(visibility(environment))
        } else {
            return Self.favoriteLabel.withVisibility(visibility(environment))
        }
    }

    private func visibility(_ environment: EnvironmentValues) -> ActionVisiblity {
        guard entity.api.canInteract(appState: environment.appState) else { return .hidden }
        return .enabled
    }
}

// MARK: - Behavior

extension FavoriteAction {
    @MainActor
    func execute(environment: EnvironmentValues) {
        guard let entity = entity as? any Community2Providing else { return }
        environment.hapticManager.play(haptic: .lightSuccess, tier: .low)
        if entity.favorited {
            environment.toastModel?.add(
                .undoable(
                    "Unfavorited",
                    icon: .lemmy.unfavorite,
                    callback: {
                        entity.updateFavorite(true)
                    },
                    color: .themedFavorite
                )
            )
        } else {
            environment.toastModel?.add(
                .basic("Favorited", icon: .lemmy.favorite, color: .themedFavorite)
            )
        }
        entity.toggleFavorite()
    }
}
