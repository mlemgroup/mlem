//
//  OpenModlogAction.swift
//  Mlem
//
//  Created by Sjmarf on 2025-10-25.
//

import Actions
import MlemMiddleware
import SwiftUI

struct OpenModlogAction: SimpleLabelAction {
    enum Content {
        case person(any Person1Providing)
    }
    
    let content: Content
}

// MARK: - Configurability

extension ActionSeed {
    static let openModlog = ActionSeed("openModlog") { entity in
        switch entity {
        case let entity as any Person1Providing: OpenModlogAction(content: .person(entity))
        default: nil
        }
    }
}

// MARK: - Appearance

extension OpenModlogAction {
    static let label: ActionLabel = .init("Modlog", icon: .lemmy.modlog)
}

// MARK: - Behavior

extension OpenModlogAction {
    @MainActor
    func execute(environment: EnvironmentValues) {
        switch content {
        case let .person(person):
            execute(person: person, environment: environment)
        }
    }

    @MainActor
    private func execute(person: any Person1Providing, environment: EnvironmentValues) {
        environment.popupModel?.showPopup(message: "Filter as...", [
            .init(title: "Subject") {
                environment.navigation?.push(.modlog(targetPerson: .init(person), moderatorPerson: nil))
            },
            .init(title: "Moderator") {
                environment.navigation?.push(.modlog(targetPerson: nil, moderatorPerson: .init(person)))
            }
        ])
    }
}
