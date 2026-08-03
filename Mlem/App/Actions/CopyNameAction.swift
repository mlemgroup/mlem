//
//  CopyNameAction.swift
//  Mlem
//
//  Created by Sjmarf on 2025-10-13.
//

import Actions
import MlemMiddleware
import SwiftUI

struct CopyNameAction: Actions.Action {
    enum Relationship { case identity, author }
    let text: String
    let relationship: Relationship
}

// MARK: - Configurability

extension ActionSeed {
    static let copyName = ActionSeed(
        "copyName",
        appearance: CopyNameAction.createAppearance(relationship: .identity)
    ) { entity in
        switch entity {
        case let entity as Person:
            CopyNameAction(text: entity.fullNameWithPrefix, relationship: .identity)
        case let entity as Community:
            CopyNameAction(text: entity.fullNameWithPrefix, relationship: .identity)
        default:
            nil
        }
    }

    static let copyAuthorName = ActionSeed(
        "copyAuthorName",
        appearance: CopyNameAction.createAppearance(relationship: .author)
    ) { entity in
        switch entity {
        case let entity as any InteractableProviding:
            if let creator = entity.creator.value {
                CopyNameAction(text: creator.fullNameWithPrefix, relationship: .author)
            } else {
                nil
            }
        default:
            nil
        }
    }
}

// MARK: - Appearance

extension CopyNameAction {
    static func createAppearance(relationship: Relationship) -> ActionAppearance {
        .init(
            relationship == .identity ? "Copy Name" : "Copy Username",
            icon: .general.copy,
            color: .themedColorfulAccent(4)
        )
    }

    func createAppearance(environment: EnvironmentValues) -> ActionAppearance {
        Self.createAppearance(relationship: self.relationship)
    }
}

// MARK: - Behavior

extension CopyNameAction {
    func execute(environment: EnvironmentValues) {
        environment.toastModel?.add(.success("Copied"))
        UIPasteboard.general.string = self.text
    }
}
