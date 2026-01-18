//
//  VisitAction.swift
//  Mlem
//
//  Created by Sjmarf on 2026-01-16.
//

import Actions
import MlemMiddleware
import SwiftUI

struct VisitAction: SimpleLabelAction {
    let instance: any InstanceStubProviding
}

// MARK: - Configurability

extension ActionSeed {
    static let visit = ActionSeed("visit") { entity in
        switch entity {
        case let entity as any InstanceStubProviding: VisitAction(instance: entity)
        default: nil
        }
    }
}

// MARK: - Appearance

extension VisitAction {
    static let label: ActionLabel = .init("Visit", icon: .lemmy.visitInstance)

    func createLabel(environment: EnvironmentValues) -> ActionLabel {
        let api = environment.appState.firstApi
        let isVisiting = api.host == instance.host && api.token == nil

        return Self.label.withVisibility(isVisiting ? .disabled : .enabled)
    }
}

// MARK: - Behavior

extension VisitAction {
    @MainActor
    func execute(environment: EnvironmentValues) {
        do {
            let account = try GuestAccount.getGuestAccount(url: instance.actorId.url)
            environment.appState.changeAccount(to: account)
            environment.appState.contentViewTab = .feeds
        } catch {
            handleError(error)
        }
    }
}
