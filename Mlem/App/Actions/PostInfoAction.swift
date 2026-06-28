//
//  PostDetailsAction.swift
//  Mlem
//
//  Created by Eric Andrews on 2026-06-23.
//

import Actions
import MlemMiddleware
import SwiftUI

struct DetailsAction: SimpleLabelAction {
    enum Content {
        case post(Post)
    }
    
    let content: Content
}

// MARK: - Configurability

extension ActionSeed {
    static let details = ActionSeed("details") { entity in
        switch entity {
        case let entity as Post: DetailsAction(content: .post(entity))
        default: nil
        }
    }
}

// MARK: - Appearance

extension DetailsAction {
    static var label: Actions.ActionLabel {
        .init(
            "Details",
            icon: .general.info,
            color: .themedAccent,
            isDestructive: false,
            visibility: .enabled
        )
    }
}

// MARK: - Behavior

extension DetailsAction {
    @MainActor
    func execute(environment: EnvironmentValues) {
        switch content {
        case let .post(post): environment.navigation?.openSheet(.postDetails(post))
        }
    }
}
