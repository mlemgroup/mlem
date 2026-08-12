//
//  EditAction.swift
//  Mlem
//
//  Created by Sjmarf on 2025-10-17.
//

import Actions
import MlemMiddleware
import SwiftUI

struct EditAction: SimpleLabelAction {
    enum Content {
        case post(Post)
        case comment(Comment)
        case message(Message)
        
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
    static let edit = ActionSeed("edit") { entity in
        switch entity {
        case let entity as Message: EditAction(content: .message(entity))
        case let entity as Comment: EditAction(content: .comment(entity))
        case let entity as Post: EditAction(content: .post(entity))
        default: nil
        }
    }
}

// MARK: - Appearance

extension EditAction {
    static let appearance: ActionAppearance = .init("Edit", icon: .general.edit)

    func createAppearance(environment: EnvironmentValues) -> ActionAppearance {
        Self.appearance.withVisibility(visibility(environment))
    }
    
    private func visibility(_ environment: EnvironmentValues) -> ActionVisiblity {
        guard content.value.api.canInteract(appState: environment.appState) else { return .hidden }

        guard let myPersonId = content.value.api.myPerson?.id else { return .hidden }
        return content.value.isOwnContent(myPersonId: myPersonId) ? .enabled : .hidden
    }
}

// MARK: - Behavior

extension EditAction {
    @MainActor
    func execute(environment: EnvironmentValues) {
        switch content {
        case let .comment(comment):
            environment.navigation?.openSheet(.editComment(comment, context: nil))
        case let .post(post):
            environment.navigation?.openSheet(.editPost(post))
        case let .message(message):
            if let editMessage = environment.editMessage {
                editMessage(message)
            } else {
                if message.isOwnMessage, let recipient = message.recipient.value {
                    environment.navigation?.push(.messageFeed(recipient, focusTextField: true, editing: message))
                } else if !message.isOwnMessage, let creator = message.creator.value {
                    environment.navigation?.push(.messageFeed(creator, focusTextField: true, editing: message))
                } else {
                    assertionFailure("Cannot edit message with no other person")
                }
            }
        }
    }
}
