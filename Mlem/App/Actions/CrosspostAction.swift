//
//  CrosspostAction.swift
//  Mlem
//
//  Created by Sjmarf on 2026-03-15.
//

import Actions
import MlemMiddleware
import SwiftUI

struct CrosspostAction: SimpleLabelAction {
    let entity: Post
}

// MARK: - Configurability

extension ActionSeed {
    static let crosspost = ActionSeed("crosspost") { entity in
        switch entity {
        case let entity as Post: CrosspostAction(entity: entity)
        default: nil
        }
    }
}

// MARK: - Appearance

extension CrosspostAction {
    static let label: ActionLabel = .init(
        "Crosspost",
        icon: .lemmy.crosspost,
        color: .themedColorfulAccent(5)
    )

    func createLabel(environment: EnvironmentValues) -> ActionLabel {
        Self.label.withVisibility(visibility(environment))
    }

    private func visibility(_ environment: EnvironmentValues) -> ActionVisiblity {
        if entity.api.canInteract(appState: environment.appState) {
            .enabled
        } else {
            .hidden
        }
    }
}

// MARK: - Behavior

extension CrosspostAction {
    @MainActor
    func execute(environment: EnvironmentValues) {
        var crossPostContent: String
        let crossPostedLabel = String(localized: "Crossposted from \(entity.actorId.description)")
        if let content = entity.content, !content.isEmpty {
            crossPostContent = "\(crossPostedLabel)\n-----\n\(content)"
        } else {
            crossPostContent = crossPostedLabel
        }
        environment.navigation?.openSheet(.createPost(
            community: nil,
            title: entity.title,
            content: crossPostContent,
            type: entity.type,
            nsfw: entity.nsfw,
            feedLoader: .init(wrappedValue: nil)
        ))
    }
}
