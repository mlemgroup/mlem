//
//  NewPostAction.swift
//  Mlem
//
//  Created by Sjmarf on 2026-02-08.
//

import Actions
import MlemMiddleware
import SwiftUI

struct NewPostAction: SimpleLabelAction {
    let entity: Community
}

// MARK: - Configurability

extension ActionSeed {
    static let newPost = ActionSeed("newPost") { entity in
        switch entity {
        case let entity as Community: NewPostAction(entity: entity)
        default: nil
        }
    }
}

// MARK: - Appearance

extension NewPostAction {
    static let label: ActionLabel = .init("New Post", icon: .lemmy.send)

    func createLabel(environment: EnvironmentValues) -> ActionLabel {
        if entity.api.canInteract(appState: environment.appState) {
            Self.label.withVisibility(.enabled)
        } else {
            Self.label.withVisibility(.hidden)
        }
    }
}

// MARK: - Behavior

extension NewPostAction {
    @MainActor
    func execute(environment: EnvironmentValues) {
        environment.navigation?.openSheet(.createPost(community: self.entity, type: nil, feedLoader: environment.feedLoader)) 
    }
}
