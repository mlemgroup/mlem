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
    
    @State var instance: (any Instance3Providing)?
    @State var person: (any Person4Providing)?
    
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
                systemImage: Icons.language
            )
            
            if let person, let instance {
                Section {
                    let selectedLanguages = instance.languages(withIds: person.discussionLanguageIds)
                    ForEach(selectedLanguages, id: \.languageCode) { language in
                        LanguageListRowBody(language: language)
                            .contextMenu {
                                Button("Remove", systemImage: Icons.signOut, role: .destructive) {
                                    Task { await updateDiscussionLanguages(with: language) }
                                }
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button("Remove", role: .destructive) {
                                    Task { await updateDiscussionLanguages(with: language) }
                                }
                                .buttonStyle(.automatic)
                                .tint(.red)
                            }
                    }
                    Button("Add Language...") {
                        navigation.openSheet(.languagePicker(selectedLanguages: Set(selectedLanguages)) { newLanguage in
                            Task { await updateDiscussionLanguages(with: newLanguage) }
                        })
                    }
                }
            }
        }
        .contentMargins(.top, 16)
        .hiddenNavigationTitle("Discussion Languages")
    }

    func updateDiscussionLanguages(with language: Locale.Language) async {
        defer { submitting = nil }

        guard let person, let instance else {
            assertionFailure()
            return
        }

        guard let id = instance.getLanguageId(for: language) else {
            assertionFailure()
            return
        }
        
        var newLangs = person.discussionLanguageIds
        if newLangs.contains(id) {
            newLangs.remove(id)
        } else {
            newLangs.insert(id)
        }
        do {
            try await person.person4.updateSettings(discussionLanguageIds: newLangs)
        } catch {
            handleError(error)
        }
    }
}
