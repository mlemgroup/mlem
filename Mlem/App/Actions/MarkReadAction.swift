//
//  MarkReadAction.swift
//  Mlem
//
//  Created by Sjmarf on 2025-11-07.
//  

import Actions
import MlemMiddleware
import SwiftUI

struct MarkReadAction: SimpleLabelAction {
    let notification: InboxNotification
}

// MARK: - Configurability

extension ActionSeed {
    static let markRead = ActionSeed("markRead") { entity in
        switch entity {
        case let entity as InboxNotification: MarkReadAction(notification: entity)
        default: nil
        }
    }
}

// MARK: - Appearance

extension MarkReadAction {
    static let markReadAppearance: ActionAppearance = .init(
        currentStateLabel: .init("Unread", icon: .lemmy.markedRead.representingState(active: false)),
        stateTransitionLabel: .init("Mark Read", icon: .lemmy.markRead),
        color: .themedRead
    )
    static let markUnreadAppearance: ActionAppearance = .init(
        currentStateLabel: .init("Read", icon: .lemmy.markedRead.representingState(active: true)),
        stateTransitionLabel: .init("Mark Unread", icon: .lemmy.markUnread),
        color: .themedRead
    )

    static var appearance: ActionAppearance { markReadAppearance }

    func createAppearance(environment: EnvironmentValues) -> ActionAppearance {
        if notification.read {
            Self.markUnreadAppearance.withVisibility(visibility(environment))
        } else {
            Self.markReadAppearance.withVisibility(visibility(environment))
        }
    }

    private func visibility(_ environment: EnvironmentValues) -> ActionVisiblity {
        guard notification.api.canInteract(appState: environment.appState) else { return .hidden }

        if case let .message(message) = notification.content, message.isOwnMessage {
            return .hidden
        }

        return .enabled
    }
}

// MARK: - Behavior

extension MarkReadAction {
    @MainActor
    func execute(environment: EnvironmentValues) {
        notification.toggleRead()
        environment.hapticManager.play(haptic: .lightSuccess, tier: .low)
    }
}
