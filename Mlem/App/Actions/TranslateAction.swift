//
//  TranslateAction.swift
//  Mlem
//
//  Created by Sjmarf on 2026-06-16.
//

import Actions
import MlemMiddleware
import NaturalLanguage
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
       if self.entity.content.translated == .untranslated {
           Self.translateLabel.withVisibility(visibility(environment))
       } else {
           Self.showOriginalLabel.withVisibility(visibility(environment))
       }
   }

    private func visibility(_ environment: EnvironmentValues) -> ActionVisiblity {
       if #available(iOS 26, *) {
           .enabled
       } else {
           .hidden
       }
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
}

@available(iOS 26, *)
extension TranslateAction {
    enum TranslationError: Error {
        case couldNotDetermineLanguage
        // swiftlint:disable:next identifier_name
        case languageUnavailable(from: Locale.Language, to: Locale.Language, status: LanguageAvailability.Status)
    }

    @MainActor
    private func internalExecute(environment: EnvironmentValues) {
        Task {
            let shouldTranslate = entity.content.translated == .untranslated
            withAnimation {
                entity.content.translated = .translating
            }
            do {
                if shouldTranslate {
                    let translated = try await translate(entity.content.string)    
                    withAnimation {
                        entity.content.translated = .translated(.init(translated))
                    }
                } else {
                    withAnimation {
                        entity.content.translated = .untranslated
                    }
                }
            } catch {
                handleError(error)
                entity.content.translated = .untranslated
            }
        }
    }

    private func translate(_ text: String) async throws -> String {
        let sourceLanguage = try await determineLanguage(of: text)
        let targetLanguage = Locale.current.language
        let availability = LanguageAvailability()
        let status = await availability.status(from: sourceLanguage, to: targetLanguage)

        guard status == .installed else {
            throw TranslationError.languageUnavailable(from: sourceLanguage, to: targetLanguage, status: status)
        }

        let session = TranslationSession.init(installedSource: sourceLanguage, target: targetLanguage)
        let result = try await session.translate(entity.content.string)
        return result.targetText
    }

    private func determineLanguage(of text: String) async throws -> Locale.Language {
        if let myInstance = entity.api.myInstance, let language = myInstance.language(withId: entity.languageId) {
            return language
        }

        if let language = await detectLanguage(of: text) {
            return language
        }

        throw TranslationError.couldNotDetermineLanguage
    }

    func detectLanguage(of text: String) async -> Locale.Language? {
        let task = Task.detached(priority: .userInitiated) {
            let recognizer = NLLanguageRecognizer()
            recognizer.processString(text)
            guard let language = recognizer.dominantLanguage else {
                return nil as Locale.Language?
            }
            return Locale.Language(identifier: language.rawValue)
        }

        return await task.value
    }
}
