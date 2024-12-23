//
//  FiltersSettingsView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-12-22.
//

import SwiftUI
import Dependencies

struct FiltersSettingsView: View {
    @Dependency(\.persistenceRepository) var persistenceRepository
    
    @Environment(Palette.self) var palette
    @Environment(FiltersTracker.self) var filtersTracker
    
    @State var filteredKeywords: [String]
    @State var newKeyword: String = ""
    
    init() {
        @Dependency(\.persistenceRepository) var persistenceRepository
        
        self._filteredKeywords = .init(wrappedValue: .init(persistenceRepository.loadFilteredKeywords()))
    }
    
    var body: some View {
        List {
            Section {
                keywordSection
            } header: {
                Text("Keyword Filters")
            } footer: {
                // swiftlint:disable:next line_length
                Text("Posts containing these keywords will not be shown. If you are a moderator or administrator for a given post, it will be present in your feed but require a tap to display the content.")
            }
        }
    }
    
    @ViewBuilder
    var keywordSection: some View {
        TextField("New keyword", text: $newKeyword)
            .textCase(.lowercase)
            .textInputAutocapitalization(.never)
            .submitLabel(.done)
            .onSubmit {
                saveNewKeyword()
            }
        
        ForEach(filteredKeywords, id: \.self) { filter in
            HStack {
                Text(filter)
                
                Spacer()
                
                // using a Button to do this makes the whole row register tap gestures :/
                Image(systemName: Icons.delete)
                    .foregroundStyle(palette.warning)
                    .onTapGesture {
                        deleteKeyword(filter)
                    }
            }
        }
    }
    
    func saveNewKeyword() {
        guard !newKeyword.isEmpty else { return }
        
        let cleanedKeyword = newKeyword.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        Task {
            do {
                let newFilteredKeywords = try await persistenceRepository.saveFilteredKeyword(cleanedKeyword)
                filteredKeywords = .init(newFilteredKeywords)
                newKeyword = ""
                filtersTracker.filteredKeywords = newFilteredKeywords
            } catch {
                handleError(error)
            }
        }
    }
    
    func deleteKeyword(_ keyword: String) {
        assert(filteredKeywords.contains(keyword), "Filtered keywords does not contain \(keyword)")
        
        Task {
            do {
                let newFilteredKeywords = try await persistenceRepository.removeFilteredKeyword(keyword)
                filteredKeywords = .init(newFilteredKeywords)
                filtersTracker.filteredKeywords = newFilteredKeywords
            } catch {
                handleError(error)
            }
        }
    }
}
