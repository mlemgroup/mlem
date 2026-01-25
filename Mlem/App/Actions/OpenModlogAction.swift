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
        case person(any Person1Providing)
    }

    enum Relationship { case identity, author }
    
    let content: Content
    let relationship: Relationship
}

// MARK: - Configurability

extension ActionSeed {
    static let openModlog = ActionSeed(
        "openModlog",
        label: OpenModlogAction.createLabel(relationship: .identity)
    ) { entity in
        switch entity {
        case let entity as any Person1Providing: OpenModlogAction(content: .person(entity), relationship: .identity)
        default: nil
        }
    }

    static let openCreatorModlog = ActionSeed(
        "openCreatorModlog",
        label: OpenModlogAction.createLabel(relationship: .author)
    ) { entity in
        switch entity {
        case let entity as Comment:
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
    static func createLabel(relationship: Relationship) -> ActionLabel {
        .init(
            relationship == .identity ? "Modlog" : "User Modlog",
            icon: .lemmy.modlog,
            color: .themedModeration
        )
    }

    func createLabel(environment: EnvironmentValues) -> ActionLabel {
        return Self.createLabel(relationship: relationship)
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
