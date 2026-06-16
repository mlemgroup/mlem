//
//  TranslateAction.swift
//  Mlem
//
//  Created by Sjmarf on 2026-06-16.
//

import Actions
import MlemMiddleware
import SwiftUI
import Translation

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
       let visibility: ActionVisiblity
       if #available(iOS 26, *) {
           visibility = .enabled
       } else {
           visibility = .hidden
       }
       return Self.translateLabel.withVisibility(visibility)
   }
}

// MARK: - Behavior

extension TranslateAction {
    @MainActor
    func execute(environment: EnvironmentValues) {
        if #available(iOS 26, *) {
            internalExecute(environment: environment)
        } else {
            assertionFailure()
        }
    }

    @MainActor
    @available(iOS 26, *)
    private func internalExecute(environment: EnvironmentValues) {
        Task {
            do {
                if entity.content.translatedMarkdown == nil {
                    let translated = try await translate(entity.content.string)    
                    withAnimation {
                        entity.content.translatedMarkdown = .init(translated)
                    }
                } else {
                    withAnimation {
                        entity.content.translatedMarkdown = nil
                    }
                }
            } catch {
                handleError(error)
            }
        }
    }

    @available(iOS 26, *)
    private func translate(_ text: String) async throws -> String {
        let session = TranslationSession.init(installedSource: .init(identifier: "de"), target: .init(identifier: "en"))
        let result = try await session.translate(entity.content.string)
        return result.targetText
    }
}
