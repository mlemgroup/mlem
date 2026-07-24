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
        color: .themedTranslationAccent
    )

    static let showOriginalLabel: ActionLabel = .init(
        "Show Original",
        icon: .general.translate,
        color: .themedTranslationAccent
    )

   static var label: ActionLabel { translateLabel }

   func createLabel(environment: EnvironmentValues) -> ActionLabel {
       if self.entity.content.translated == .untranslated {
           Self.translateLabel
       } else {
           Self.showOriginalLabel
       }
   }
}

// MARK: - Behavior

extension TranslateAction {
    @MainActor
    func execute(environment: EnvironmentValues) {
        internalExecute(environment: environment)
    }
}

extension TranslateAction {
    enum TranslationError: Error {
        case couldNotDetermineLanguage
        // swiftlint:disable:next identifier_name
        case languageUnavailable(from: Locale.Language, to: Locale.Language, status: LanguageAvailability.Status)
    }

    @MainActor
    private func internalExecute(environment: EnvironmentValues) {
        Task { @MainActor in
            let shouldTranslate = entity.content.translated == .untranslated
            do {
                if shouldTranslate {
                    withAnimation {
                        entity.content.translated = .translating
                    }
                    let (translated, language) = try await translate(entity.content.string)    
                    withAnimation(.easeInOut(duration: 1.0)) {
                        entity.content.translated = .translated(.init(translated), language)
                    }
                } else {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        entity.content.translated = .untranslated
                    }
                }
                
            } catch let TranslationError.languageUnavailable(from: source, to: target, status: .unsupported) {
                showUnsupportedToast(environment: environment, source: source, target: target)
                entity.content.translated = .untranslated
            } catch let TranslationError.languageUnavailable(from: source, to: target, status: .supported) {
                if let navigation = environment.navigation {
                    openDownloadSheet(navigation: navigation, source: source, target: target)
                } else {
                    assertionFailure()
                }
                entity.content.translated = .untranslated
            } catch {
                handleError(error)
                entity.content.translated = .untranslated
            }
        }
    }

    private func translate(_ text: String) async throws -> (String, Locale.Language) {
        let sourceLanguage = try await determineLanguage(of: text)
        let targetLanguage = Locale.current.language
        let availability = LanguageAvailability()
        let status = await availability.status(from: sourceLanguage, to: targetLanguage)

        guard status == .installed else {
            throw TranslationError.languageUnavailable(from: sourceLanguage, to: targetLanguage, status: status)
        }

        let session = TranslationSession.init(installedSource: sourceLanguage, target: targetLanguage)
        let result = try await session.translate(entity.content.string)
        return (result.targetText, sourceLanguage)
    }

    private func determineLanguage(of text: String) async throws -> Locale.Language {
        if let myInstance = entity.api.myInstance,
            let language = myInstance.language(withId: entity.languageId),
            language.languageCode != Locale.current.language.languageCode {
            return language
        }

        if let language = await detectLanguage(of: text) {
            return language
        }

        throw TranslationError.couldNotDetermineLanguage
    }

    private func showUnsupportedToast(
        environment: EnvironmentValues,
        source: Locale.Language,
        target: Locale.Language
    ) {
        let sourceLabel = environment.locale.localizedString(forLanguageCode: source.languageCode?.identifier ?? "") ?? ""
        let targetLabel = environment.locale.localizedString(forLanguageCode: target.languageCode?.identifier ?? "") ?? ""
        environment.toastModel?.add(.basic(
            "Unsupported Language",
            subtitle: "Cannot translate from \(sourceLabel) to \(targetLabel).",
            icon: .general.translate,
            color: .themedTranslationAccent,
            duration: 5
        ))

    }

    @MainActor
    private func openDownloadSheet(
        navigation: NavigationLayer,
        source: Locale.Language,
        target: Locale.Language
    ) {
        let newConfig = TranslationSession.Configuration(source: source, target: target)

        navigation.dismissingActionSheet {
            let model = NavigationModel.main // Can't use navigation.model; it's nil
            if newConfig == model.translationConfiguration.sessionConfig {
                model.translationConfiguration.sessionConfig?.invalidate()
            } else {
                model.translationConfiguration.sessionConfig = newConfig
            }
            model.translationConfiguration.presentationNeeded = true
        }
    }

    private func detectLanguage(of text: String) async -> Locale.Language? {
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
