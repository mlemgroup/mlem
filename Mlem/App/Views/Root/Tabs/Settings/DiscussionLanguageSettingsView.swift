//
//  DiscussionLanguageSettingsView.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-02-06.
//

import MlemMiddleware
import SwiftUI

struct DiscussionLanguageSettingsView: View {
    @Environment(Palette.self) var palette
    @Environment(NavigationLayer.self) var navigation
    @Environment(\.locale) var userLocale
    
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
                    ForEach(instance.languages(withIds: person.discussionLanguageIds), id: \.languageCode) { language in
                        languageRowLabelView(language)
                    }
                    Button("Add Language...") {
                        navigation.openSheet(.languagePicker { newLanguage in
                            print(newLanguage)
                        })
                    }
                }
            }

//            if let languages = person?.discussionLanguages, !languages.contains(0) {
//                Section {
//                    Label("You will not see most content if Undetermined is not selected.", systemImage: Icons.warningFill)
//                        .foregroundStyle(palette.warning)
//                }
//            }
//
//            Section {
//                if let instance, let person {
//                    ForEach(Array(instance.allLanguages.enumerated()), id: \.offset) {
//                        languageButtonView($1, index: $0, person: person)
//                    }
//                } else {
//                    ProgressView()
//                        .task {
//                            do {
//                                try await (person, instance, _) = AppState.main.firstApi.getMyPerson()
//                            } catch {
//                                handleError(error)
//                            }
//                        }
//                }
//            }
        }
        .contentMargins(.top, 16)
    }
    
//    @ViewBuilder
//    func languageButtonView(_ language: ContentLanguage, index: Int, person: any Person4Providing) -> some View {
//        Button {
//            if submitting == nil {
//                submitting = index
//                Task {
//                    await updateDiscussionLanguages(with: index)
//                }
//            }
//        } label: {
//            HStack {
//                languageRowLabelView(language)
//                Spacer()
//                if submitting == index {
//                    ProgressView()
//                } else if person.discussionLanguages.contains(index) {
//                    Image(systemName: Icons.success)
//                        .foregroundStyle(palette.accent)
//                }
//            }
//            .contentShape(.rect)
//        }
//        .buttonStyle(.plain)
//    }
//
    @ViewBuilder
    func languageRowLabelView(_ language: Locale.Language) -> some View {
        let code = language.languageCode?.identifier ?? ""
        let locale = Locale(languageCode: language.languageCode)
        VStack(alignment: .leading) {
            Text(locale.localizedString(forLanguageCode: code)?.capitalized ?? "")
            Text(userLocale.localizedString(forLanguageCode: code) ?? "")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
//
//    func updateDiscussionLanguages(with id: Int) async {
//        defer { submitting = nil }
//
//        guard let person else {
//            assertionFailure("No person found")
//            return
//        }
//
//        var newLangs = person.discussionLanguages
//        if newLangs.contains(id) {
//            newLangs.remove(id)
//        } else {
//            newLangs.insert(id)
//        }
//        do {
//            try await person.person4.updateSettings(discussionLanguages: newLangs)
//        } catch {
//            handleError(error)
//        }
//    }
}
