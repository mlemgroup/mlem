//
//  LanguagePickerSheetView.swift
//  Mlem
//
//  Created by Sjmarf on 2025-02-28.
//

import SwiftUI

struct LanguagePickerSheetView: View {
    @Environment(AppState.self) var appState
    @Environment(\.dismiss) var dismiss
    @Environment(\.locale) private var userLocale

    let selectedLanguages: Set<Locale.Language>
    let callback: (Locale.Language) -> Void
    
    @State var query: String = ""
    @State var editing: Bool = true
    @State var focused: Bool = true

    var allLanguages: [Locale.Language] {
        appState.firstSession.instance?.allLanguages ?? []
    }
    
    var suggestedLanguages: [Locale.Language] {
        let deviceLanguageCodes = Locale.preferredLanguages.compactMap {
            $0.split(separator: "-").first
        }.map(String.init).uniqued()
        
        var validDeviceLanguages: Set<String> = .init()
        for language in allLanguages {
            let code = language.languageCode?.identifier ?? ""
            if deviceLanguageCodes.contains(code) {
                validDeviceLanguages.insert(code)
            }
        }
        
        return deviceLanguageCodes
            .filter { validDeviceLanguages.contains($0) }
            .map(Locale.Language.init)
            .filter { !selectedLanguages.contains($0) }
    }
    
    var searchResults: [Locale.Language] {
        allLanguages.filter { language in
            let code = language.languageCode?.identifier ?? ""
            let locale = Locale(languageCode: language.languageCode)
            
            if let name = locale.localizedString(forLanguageCode: code) {
                if name.localizedCaseInsensitiveContains(query) {
                    return true
                }
            }
            
            if let name = userLocale.localizedString(forLanguageCode: code) {
                if name.localizedCaseInsensitiveContains(query) {
                    return true
                }
            }
            
            return false
        }
    }
    
    var body: some View {
        Form {
            if query.isEmpty {
                Section("Suggested Languages") {
                    ForEach(suggestedLanguages, id: \.languageCode, content: languageRow)
                }
                Section("All Languages") {
                    ForEach(allLanguages, id: \.languageCode, content: languageRow)
                }
            } else {
                Section {
                    ForEach(searchResults, id: \.languageCode, content: languageRow)
                }
            }
        }
        .contentMargins(.top, searchResults.isEmpty ? nil : 16)
        .navigationTitle("Choose Language")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack(spacing: 0) {
                    SearchBar("Search", text: $query, isEditing: $editing)
                        .isInitialFirstResponder(true)
                        .focused($focused)
                        .autocorrectionDisabled()
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Cancel") { dismiss() }
            }
        }
    }
    
    func languageRow(_ language: Locale.Language) -> some View {
        LanguageListRowBody(language: language)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(.rect)
            .onTapGesture {
                callback(language)
                dismiss()
            }
    }
}
