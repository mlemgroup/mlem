//
//  DiscussionLanguageSettingsView.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-02-06.
//

import MlemMiddleware
import SwiftUI

struct DiscussionLanguageSettingsView: View {
    @Environment(NavigationLayer.self) var navigation
    
    @State var instance: Instance?
    @State var person: Person?
    
    @State var submitting: Int?
    
    init() {
        if let firstInstance = AppState.main.firstApi.myInstance {
            self._instance = .init(wrappedValue: firstInstance)
        }
        if let firstPerson = AppState.main.firstPerson {
            self._person = .init(wrappedValue: firstPerson)
        }
    }
    
    var body: some View {
        Form {
            SettingsHeaderView(
                title: "Discussion Languages",
                description: "Choose which languages appear in your feed. Posts and comments in other languages will be hidden.",
                icon: .settings.language
            )
            
            if let person, let instance, let languageIds = person.discussionLanguageIds.value {
                Section {
                    let selectedLanguages = instance.languages(withIds: languageIds)
                    ForEach(selectedLanguages, id: \.languageCode) { language in
                        LanguageListRowBody(language: language)
                            .contextMenu {
                                Button("Remove", icon: .general.signOut, role: .destructive) {
                                    Task { await updateDiscussionLanguages(with: language, languages: languageIds) }
                                }
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button("Remove", role: .destructive) {
                                    Task { await updateDiscussionLanguages(with: language, languages: languageIds) }
                                }
                                .buttonStyle(.automatic)
                                .tint(.red)
                            }
                    }
                    Button("Add Language...") {
                        navigation.openSheet(.languagePicker(selectedLanguages: Set(selectedLanguages)) { newLanguage in
                            Task { await updateDiscussionLanguages(with: newLanguage, languages: languageIds) }
                        })
                    }
                }
            }
        }
        .contentMargins(.top, 16)
        .hiddenNavigationTitle("Discussion Languages")
    }

    func updateDiscussionLanguages(with language: Locale.Language, languages: Set<Int>) async {
        defer { submitting = nil }

        guard let person, let instance else {
            assertionFailure()
            return
        }

        guard let id = instance.getLanguageId(for: language) else {
            assertionFailure()
            return
        }
        
        guard let updateSettings = person.updateSettings else {
            assertionFailure()
            return
        }
        
        var newLangs = languages
        if newLangs.contains(id) {
            newLangs.remove(id)
        } else {
            newLangs.insert(id)
        }
        do {
            try await updateSettings(.init(discussionLanguageIds: newLangs))
        } catch {
            handleError(error)
        }
    }
}
