//
//  ReplyAction.swift
//  Mlem
//
//  Created by Sjmarf on 2025-10-25.
//

import Actions
import MlemMiddleware
import SwiftUI

struct ReplyAction: SimpleLabelAction {
    enum Content {
        case post(Post)
        case comment(Comment)
        case message(any Message2Providing)
        
        var value: any OwnershipProviding {
            switch self {
            case let .post(post): post
            case let .comment(comment): comment
            case let .message(message): message
            }
        }
    }
    
    let content: Content
}

// MARK: - Configurability

extension ActionSeed {
    static let reply = ActionSeed("reply") { entity in
        switch entity {
        case let entity as Post: ReplyAction(content: .post(entity))
        case let entity as Comment: ReplyAction(content: .comment(entity))
        case let entity as any Message2Providing: ReplyAction(content: .message(entity))
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
        guard content.value.api.canInteract(appState: environment.appState) else { return .hidden }

        // Don't show the reply action for messages in the message feed
        if case .message = self.content, case .messageFeed = environment.navigation?.path.last?.page {
            return .hidden
        }

        return .enabled
    }
}

// MARK: - Behavior

extension ReplyAction {
    @MainActor
    func execute(environment: EnvironmentValues) {
        guard let navigation = environment.navigation else {
            assertionFailure()
            return
        }

        switch self.content {
        case let .post(post):
            navigation.openSheet(.createComment(.post(post), commentTreeTracker: environment.commentTreeTracker))
        case let .comment(comment):
            navigation.openSheet(.createComment(.comment(comment), commentTreeTracker: environment.commentTreeTracker))
        case let .message(message):
            navigation.push(.messageFeed(message.creator, focusTextField: true))
        }
    }
}
