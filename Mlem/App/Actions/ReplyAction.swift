//
//  ReplyAction.swift
//  Mlem
//
//  Created by Sjmarf on 2025-10-25.
//

import Actions
import MlemMiddleware
import SwiftUI

struct ReplyAction: ConfigurableAction {
    let entity: any Interactable2Providing
}

// MARK: - Configurability

extension ActionSeed {
    static let reply = ActionSeed("reply") { entity in
        switch entity {
        case let entity as any Interactable2Providing: ReplyAction(entity: entity)
        default: nil
        }
    }
}

// MARK: - Appearance

extension ReplyAction {
    static let label: ActionLabel = .init("Reply", icon: .lemmy.reply)

    func createLabel(environment: EnvironmentValues) -> ActionLabel {
        Self.label.withVisibility(visibility(environment))
    }

    private func visibility(_ environment: EnvironmentValues) -> ActionVisiblity {
        guard entity.api.canInteract(appState: environment.appState) else { return .hidden }
        return .enabled
    }
}

// MARK: - Behavior

extension ReplyAction {
    @MainActor
    func execute(environment: EnvironmentValues) {
        let context: CommentEditorView.Context
        switch entity {
        case let entity as any Post2Providing:
            context = .post(entity)
        case let entity as any Comment2Providing:
            context = .comment(entity)
        default:
            assertionFailure()
            return
        }

        environment.navigation?.openSheet(
            .createComment(context, commentTreeTracker: environment.commentTreeTracker)
        )
    }
}
