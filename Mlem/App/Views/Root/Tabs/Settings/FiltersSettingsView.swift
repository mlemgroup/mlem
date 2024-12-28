//
//  FiltersSettingsView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-12-22.
//

import Dependencies
import SwiftUI

struct FiltersSettingsView: View {
    @Dependency(\.persistenceRepository) var persistenceRepository
    
    @Setting(\.keywordFilterEnabled) var keywordFilterEnabled
    
    @Environment(Palette.self) var palette
    @Environment(FiltersTracker.self) var filtersTracker
    
    @State var newKeyword: String = ""
    
    init() {
        @Dependency(\.persistenceRepository) var persistenceRepository
    }
    
    var body: some View {
        List {
            Section {
                Toggle("Enable Keyword Filters", isOn: $keywordFilterEnabled)
            } header: {
                Text("Keyword Filters")
            }
            
            Section {
                keywordSection
            } footer: {
                // swiftlint:disable:next line_length
                Text("Posts with these keywords in their titles will be hidden. If you are a moderator or administrator of a matching post, it will appear in your feed but require you to tap to view its content.")
            }
        }
    }
    
    @ViewBuilder
    var keywordSection: some View {
        TextField("New Keyword...", text: $newKeyword)
            .textCase(.lowercase)
            .textInputAutocapitalization(.never)
            .submitLabel(.done)
            .onSubmit {
                saveNewKeyword()
            }
        
        ForEach(filtersTracker.filteredKeywords.sorted(by: <), id: \.self) { filter in
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
            await filtersTracker.addFilteredKeyword(cleanedKeyword)
            newKeyword = ""
        }
    }
    
    func deleteKeyword(_ keyword: String) {
        guard filtersTracker.filteredKeywords.contains(keyword) else {
            return
        }
        
        Task {
            await filtersTracker.removeFilteredKeyword(keyword)
        }
    }
}
