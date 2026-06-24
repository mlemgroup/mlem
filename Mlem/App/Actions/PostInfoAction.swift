//
//  PostInfoAction.swift
//  Mlem
//
//  Created by Eric Andrews on 2026-06-23.
//

import Actions
import MlemMiddleware
import SwiftUI

struct PostInfoAction: SimpleLabelAction {
    let entity: Post
}

// MARK: - Configurability

extension ActionSeed {
    static let postInfo = ActionSeed("postInfo") { entity in
        switch entity {
        case let entity as Post: PostInfoAction(entity: entity)
        default: nil
        }
    }
}

// MARK: - Appearance

extension PostInfoAction {
    static var label: Actions.ActionLabel {
        .init("Post Info",
              icon: .general.info,
              color: .themedAccent,
              isDestructive: false,
              visibility: .enabled
        )
    }
}

// MARK: - Behavior

extension PostInfoAction {
    @MainActor
    func execute(environment: EnvironmentValues) {
        environment.navigation?.openSheet(.postInfo(entity))
    }
}
