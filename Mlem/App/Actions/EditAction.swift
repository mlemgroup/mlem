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
        case comment(any Comment1Providing)
        case message(any Message1Providing)
        
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
        case let entity as any Message1Providing: EditAction(content: .message(entity))
        case let entity as any Comment1Providing: EditAction(content: .comment(entity))
        case let entity as Post: EditAction(content: .post(entity))
        default: nil
        }
    }
}

// MARK: - Appearance

extension EditAction {
    static let label: ActionLabel = .init("Edit", icon: .general.edit)
    
    func createLabel(environment: EnvironmentValues) -> ActionLabel {
        Self.label.withVisibility(visibility(environment))
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
            if let comment = comment as? any Comment2Providing {
                environment.navigation?.openSheet(.editComment(comment.comment2, context: nil))
            } else {
                assertionFailure()
            }
        case let .post(post):
            environment.navigation?.openSheet(.editPost(post))
        case let .message(message):
            if let message = message as? any Message2Providing {
                if let editMessage = environment.editMessage {
                    editMessage(message.message2)
                } else {
                    let otherPerson = message.isOwnMessage ? message.recipient : message.creator
                    environment.navigation?.push(.messageFeed(otherPerson, focusTextField: true, editing: message))
                }
            } else {
                assertionFailure()
            }
        }
    }
}
