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
    static let appearance: ActionAppearance = .init(
        "Crosspost",
        icon: .lemmy.crosspost,
        color: .themedColorfulAccent(5)
    )

    func createAppearance(environment: EnvironmentValues) -> ActionAppearance {
        Self.appearance.withVisibility(visibility(environment))
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
        environment.navigation?.openSheet(.createPost(
            community: nil,
            title: entity.title,
            content: .callback(createCrosspostContent),
            type: entity.type,
            nsfw: entity.nsfw,
            feedLoader: nil
        ))
    }

    private func createCrosspostContent() async -> String {
        var url: URL

        do {
            try await entity.upgrade()
            let communityActorId = try entity.community.tryValue.actorId
            let api = ApiClient.getApiClient(url: communityActorId.url.removingPathComponents(), username: nil)
            let community = try await api.getCommunity(url: communityActorId.url)
            url = community.resolvableUrl(from: .provider)
        } catch {
            handleError(error, silent: true)
            url = entity.resolvableUrl(from: .provider)
        }

        let crossPostedLabel = String(localized: "Crossposted from \(url.description)")
        if let content = entity.content, !content.isEmpty {
            return "\(crossPostedLabel)\n-----\n\(content)"
        } else {
            return crossPostedLabel
        }
    }
}
