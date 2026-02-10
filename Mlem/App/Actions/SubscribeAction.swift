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
    let entity: any Community1Providing
}

// MARK: - Configurability

extension ActionSeed {
    static let subscribe = ActionSeed("subscribe") { entity in
        switch entity {
        case let entity as any Community1Providing: SubscribeAction(entity: entity)
        default: nil
        }
    }
}

// MARK: - Appearance

extension SubscribeAction {
    static let subscribeLabel: ActionLabel = .init(
        "Subscribe",
        icon: .lemmy.subscribe,
        color: .themedPositive
    )
    static let unsubscribeLabel: ActionLabel = .init(
        "Unsubscribe",
        icon: .lemmy.unsubscribe,
        color: .themedNegative
    )
    
    static var label: ActionLabel { subscribeLabel }

    func createLabel(environment: EnvironmentValues) -> ActionLabel {
        guard let subscribed = entity.subscribed_  else {
            return Self.subscribeLabel.withVisibility(.hidden)
        }
        if subscribed {
            return Self.unsubscribeLabel.withVisibility(visibility(environment))
        } else {
            return Self.subscribeLabel.withVisibility(visibility(environment))
        }
    }

    private func visibility(_ environment: EnvironmentValues) -> ActionVisiblity {
        guard entity.api.canInteract(appState: environment.appState) else { return .hidden }
        return .enabled
    }
}

// MARK: - Behavior

extension SubscribeAction {
    @MainActor
    func execute(environment: EnvironmentValues) {
        guard let entity = entity as? any Community2Providing else { return }
        environment.hapticManager.play(haptic: .lightSuccess, tier: .low)
        let wasFavorited = entity.favorited
        if entity.subscribed {
            environment.toastModel?.add(
                .undoable(
                    "Unsubscribed",
                    icon: .lemmy.didUnsubscribe,
                    callback: {
                        if wasFavorited {
                            entity.updateFavorite(true)
                        } else {
                            entity.updateSubscribe(true)
                        }
                    },
                    color: .themedAccent
                )
            )
        }
        entity.toggleSubscribe()
    }
}
