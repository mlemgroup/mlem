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
    static let markReadLabel: ActionLabel = .init(
        "Mark Read",
        icon: .lemmy.markRead,
        color: .themedRead
    )
    static let markUnreadLabel: ActionLabel = .init(
        "Mark Unread",
        icon: .lemmy.markUnread,
        color: .themedRead
    )
    
    static var label: ActionLabel { markReadLabel }

    func createLabel(environment: EnvironmentValues) -> ActionLabel {
        if notification.read {
            Self.markUnreadLabel.withVisibility(visibility(environment))
        } else {
            Self.markReadLabel.withVisibility(visibility(environment))
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
