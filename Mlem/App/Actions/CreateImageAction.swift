//
//  CreateImageAction.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-12-06.
//

import Actions
import MlemMiddleware
import SwiftUI

struct CreateImageAction: SimpleLabelAction {
    enum Content {
        case comment(any Comment1Providing)
        case post(Post)
    }
    
    let content: Content
}

// MARK: - Configurability

extension ActionSeed {
    static let createImage = ActionSeed("createImage") { entity in
        switch entity {
        case let entity as Post: CreateImageAction(content: .post(entity))
        case let entity as any Comment1Providing: CreateImageAction(content: .comment(entity))
        default: nil
        }
    }
}

// MARK: - Appearance

extension CreateImageAction {
    static let label: ActionLabel = .init("Create Image", icon: .general.createImage)

    func createLabel(environment: EnvironmentValues) -> ActionLabel {
        Self.label.withVisibility(visibility(environment))
    }

    private func visibility(_ environment: EnvironmentValues) -> ActionVisiblity {
        environment.feedContext == .post ? .enabled : .hidden
    }
}

// MARK: - Behavior

extension CreateImageAction {
    @MainActor
    func execute(environment: EnvironmentValues) {
        guard let navigation = environment.navigation else {
            assertionFailure()
            return
        }

        switch self.content {
        case let .post(post):
            navigation.openSheet(.exportPostImage(post))
        case let .comment(comment):
            navigation.openSheet(.createCommentImage(comment, tracker: environment.commentTreeTracker))
        }
    }
}
