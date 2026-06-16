//
//  TranslateAction.swift
//  Mlem
//
//  Created by Sjmarf on 2026-06-16.
//

import Actions
import MlemMiddleware
import SwiftUI

struct TranslateAction: SimpleLabelAction {
    let entity: Comment
}

// MARK: - Configurability

extension ActionSeed {
    static let translate = ActionSeed("translate") { entity in
        switch entity {
        case let entity as Comment: TranslateAction(entity: entity)
        default: nil
        }
    }
}

// MARK: - Appearance

extension TranslateAction {
    static let translateLabel: ActionLabel = .init(
        "Translate",
        icon: .general.translate,
        color: .themedColorfulAccent(9)
    )

    static let showOriginalLabel: ActionLabel = .init(
        "Show Original",
        icon: .general.translate,
        color: .themedColorfulAccent(9)
    )

   static var label: ActionLabel { translateLabel }

   func createLabel(environment: EnvironmentValues) -> ActionLabel {
       Self.translateLabel
   }
}

// MARK: - Behavior

extension TranslateAction {
    @MainActor
    func execute(environment: EnvironmentValues) {
    }
}
