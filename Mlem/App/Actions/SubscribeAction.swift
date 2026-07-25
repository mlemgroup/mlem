//
//  SubscribeAction.swift
//  Mlem
//
//  Created by Sjmarf on 2026-02-08.
//

import Actions
import MlemMiddleware
import SwiftUI

struct SubscribeAction: SimpleLabelAction {
    let entity: Community
}

// MARK: - Configurability

extension ActionSeed {
    static let subscribe = ActionSeed("subscribe") { entity in
        switch entity {
        case let entity as Community: SubscribeAction(entity: entity)
        default: nil
        }
    }
}

// MARK: - Appearance

extension SubscribeAction {
    static let subscribeAppearance: ActionAppearance = .init(
        currentStateLabel: .init("Unsubscribed", icon: .lemmy.subscribed.representingState(active: false)),
        stateTransitionLabel: .init("Subscribe", icon: .lemmy.subscribe),
        color: .themedPositive
    )
    static let unsubscribeAppearance: ActionAppearance = .init(
        currentStateLabel: .init("Subscribed", icon: .lemmy.subscribed.representingState(active: true)),
        stateTransitionLabel: .init("Unsubscribe", icon: .lemmy.unsubscribe),
        color: .themedNegative
    )

    static var appearance: ActionAppearance { subscribeAppearance }

    func createAppearance(environment: EnvironmentValues) -> ActionAppearance {
        guard let subscription = entity.subscription.value else {
            return Self.subscribeAppearance.withVisibility(.hidden)
        }
        if subscription.subscribed {
            return Self.unsubscribeAppearance.withVisibility(visibility(environment))
        } else {
            return Self.subscribeAppearance.withVisibility(visibility(environment))
        }
    }

    private func visibility(_ environment: EnvironmentValues) -> ActionVisiblity {
        guard entity.api.canInteract(appState: environment.appState),
              entity.subscription.value != nil,
              entity.updateSubscribed != nil else { return .hidden }
        return .enabled
    }
}

// MARK: - Behavior

extension SubscribeAction {
    @MainActor
    func execute(environment: EnvironmentValues) {
        guard let updateSubscribed = entity.updateSubscribed,
              let subscription = entity.subscription.value,
              let updateFavorite = entity.updateFavorite else { return }
        environment.hapticManager.play(haptic: .lightSuccess, tier: .low)
        let wasFavorited = entity.favorited
        if subscription.subscribed {
            environment.toastModel?.add(
                .undoable(
                    "Unsubscribed",
                    icon: .lemmy.didUnsubscribe,
                    callback: {
                        if wasFavorited {
                            updateFavorite(true)
                        } else {
                            updateSubscribed(true)
                        }
                    },
                    color: .themedAccent
                )
            )
        }
        updateSubscribed(!subscription.subscribed)
    }
}
