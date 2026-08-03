//
//  OpenModlogAction.swift
//  Mlem
//
//  Created by Sjmarf on 2025-10-25.
//

import Actions
import MlemMiddleware
import SwiftUI

struct OpenModlogAction: Actions.Action {
    enum Content {
        case person(Person)
    }

    enum Relationship { case identity, author }
    
    let content: Content
    let relationship: Relationship
}

// MARK: - Configurability

extension ActionSeed {
    static let openModlog = ActionSeed(
        "openModlog",
        appearance: OpenModlogAction.createAppearance(relationship: .identity)
    ) { entity in
        switch entity {
        case let entity as Person: OpenModlogAction(content: .person(entity), relationship: .identity)
        default: nil
        }
    }

    static let openCreatorModlog = ActionSeed(
        "openCreatorModlog",
        appearance: OpenModlogAction.createAppearance(relationship: .author)
    ) { entity in
        switch entity {
        case let entity as any InteractableProviding:
            if let creator = entity.creator.value {
                OpenModlogAction(content: .person(creator), relationship: .author)
            } else {
                nil
            }
        default: nil
        }
    }
}

// MARK: - Appearance

extension OpenModlogAction {
    static func createAppearance(relationship: Relationship) -> ActionAppearance {
        .init(
            relationship == .identity ? "Modlog" : "User Modlog",
            icon: .lemmy.modlog,
            color: .themedModeration
        )
    }

    func createAppearance(environment: EnvironmentValues) -> ActionAppearance {
        Self.createAppearance(relationship: relationship)
    }
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
    private func execute(person: Person, environment: EnvironmentValues) {
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
