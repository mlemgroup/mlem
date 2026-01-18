//
//  OpenInBrowserAction.swift
//  Mlem
//
//  Created by Sjmarf on 2026-01-16.
//

import Actions
import MlemMiddleware
import SwiftUI

struct OpenInBrowserAction: SimpleLabelAction {
    let url: URL
}

// MARK: - Configurability

extension ActionSeed {
    static let openInBrowser = ActionSeed("openInBrowser") { entity in
        switch entity {
        case let entity as any Sharable: OpenInBrowserAction(url: entity.url())
        case let entity as any InstanceStubProviding: OpenInBrowserAction(url: entity.actorId.url)
        default: nil
        }
    }
}

// MARK: - Appearance

extension OpenInBrowserAction {
    static let label: ActionLabel = .init("Open in Browser", icon: .general.browser)
}

// MARK: - Behavior

extension OpenInBrowserAction {
    @MainActor
    func execute(environment: EnvironmentValues) {
        openLinkAsWebsite(url: url)
    }
}
