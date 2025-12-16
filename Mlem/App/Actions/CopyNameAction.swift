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
        label: CopyNameAction.createLabel(relationship: .identity)
    ) { entity in
        switch entity {
        case let entity as any Person1Providing:
            CopyNameAction(text: entity.fullNameWithPrefix, relationship: .identity)
        default:
            nil
        }
    }

    static let copyAuthorName = ActionSeed(
        "copyAuthorName",
        label: CopyNameAction.createLabel(relationship: .author)
    ) { entity in
        switch entity {
        case let entity as any Comment2Providing:
            CopyNameAction(text: entity.creator.fullNameWithPrefix, relationship: .author)
        default:
            nil
        }
    }
}

// MARK: - Appearance

extension CopyNameAction {
    static func createLabel(relationship: Relationship) -> ActionLabel {
        .init(
            relationship == .identity ? "Copy Name" : "Copy Username",
            icon: .general.copy
        )
    }

    func createLabel(environment: EnvironmentValues) -> ActionLabel {
        Self.createLabel(relationship: self.relationship)
    }
}

// MARK: - Behavior

extension CopyNameAction {
    func execute(environment: EnvironmentValues) {
        environment.toastModel?.add(.success("Copied"))
        UIPasteboard.general.string = self.text
    }
}
