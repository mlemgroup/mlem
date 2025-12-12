//
//  SendMessageAction.swift
//  Mlem
//
//  Created by Sjmarf on 2025-10-25.
//

import Actions
import MlemMiddleware
import SwiftUI

struct SendMessageAction: SimpleLabelAction {
    let entity: any Person1Providing
}

// MARK: - Configurability

extension ActionSeed {
    static let sendMessage = ActionSeed("sendMessage") { entity in
        switch entity {
        case let entity as any Person1Providing: SendMessageAction(entity: entity)
        default: nil
        }
    }
}

// MARK: - Appearance

extension SendMessageAction {
    static let label: ActionLabel = .init("Send Message", icon: .lemmy.message)

    func createLabel(environment: EnvironmentValues) -> ActionLabel {
        Self.label.withVisibility(visibility(environment))
    }

    private func visibility(_ environment: EnvironmentValues) -> ActionVisiblity {
        if environment.appState.firstPerson?.actorId == entity.actorId {
            return .hidden
        }
        if environment.isInMessageFeed {
            return .hidden
        }
        return .enabled
    }
}

// MARK: - Behavior

extension SendMessageAction {
    @MainActor
    func execute(environment: EnvironmentValues) {
        environment.navigation?.openSheet(.messageFeed(self.entity, focusTextField: true)) 
    }
}
