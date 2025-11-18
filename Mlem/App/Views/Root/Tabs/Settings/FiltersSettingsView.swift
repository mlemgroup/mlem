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
    
    @Setting(\.filters_keywordFilterEnabled) var keywordFilterEnabled
    @Setting(\.filters_literalFilterEnabled) var literalFilterEnabled
    
    @Environment(FiltersTracker.self) var filtersTracker
    @Environment(NavigationLayer.self) var navigation
    
    @State var newKeyword: String = ""
    @State var newLiteral: String = ""
    
    init() {
        @Dependency(\.persistenceRepository) var persistenceRepository
    }
    
    var body: some View {
        Form {
            Section {
                Toggle("Enable Keyword Filters", icon: .settings.keywordFilter, isOn: $keywordFilterEnabled)
                Toggle("Enable Literal Filters", icon: .settings.keywordFilter, isOn: $literalFilterEnabled)
            }
            
            Section {
                keywordSection
            } footer: {
                // swiftlint:disable:next line_length
                Text("Posts with these keywords in their titles will be hidden. If you are a moderator or administrator of a matching post, it will appear in your feed but require you to tap to view its content.")
            }
            
            Section {
                literalSection
            } footer: {
                // swiftlint:disable:next line_length
                Text("Posts with these literal strings in their titles will be hidden. If you are a moderator or administrator of a matching post, it will appear in your feed but require you to tap to view its content.")
            }
        }
        .withConditionalLabelStyle()
        .navigationTitle("Filters")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu("More...", icon: .general.toolbarMenu) {
                    Button("Export...", icon: .general.export) {
                        Task {
                            if let url = await downloadTextToFileSystem(
                                fileName: "keywords.txt",
                                text: filtersTracker.rawKeywords.joined(separator: "\n")
                            ) {
                                navigation.model?.shareInfo = .init(url: url)
                            } else {
                                ToastModel.main.add(.failure())
                            }
                        }
                    }
                    Button("Import...", icon: .general.import) {
                        navigation.showFilePicker(types: [.plainText]) { data in
                            let text = String(data: data, encoding: .utf8) ?? ""
                            await filtersTracker.resetFilteredKeywords(
                                to: Set(text.split(separator: "\n").map(String.init))
                            )
                        }
                    }
                }
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
        
        ForEach(filtersTracker.rawKeywords.sorted(by: <), id: \.self) { keyword in
            HStack {
                Text(keyword)
                
                Spacer()
                
                // using a Button to do this makes the whole row register tap gestures :/
                Image(icon: .general.delete)
                    .foregroundStyle(.themedWarning)
                    .onTapGesture {
                        deleteKeyword(keyword)
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
        guard filtersTracker.rawKeywords.contains(keyword) else {
            return
        }
        
        Task {
            await filtersTracker.removeFilteredKeyword(keyword)
        }
    }
    
    @ViewBuilder
    var literalSection: some View {
        TextField("New Literal...", text: $newLiteral)
            .textCase(.lowercase)
            .textInputAutocapitalization(.never)
            .submitLabel(.done)
            .onSubmit {
                saveNewLiteral()
            }
        
        ForEach(filtersTracker.literals.sorted(by: <), id: \.self) { literal in
            HStack {
                Text(literal)
                
                Spacer()
                
                // using a Button to do this makes the whole row register tap gestures :/
                Image(icon: .general.delete)
                    .foregroundStyle(.themedWarning)
                    .onTapGesture {
                        deleteLiteral(literal)
                    }
            }
        }
    }
    
    func saveNewLiteral() {
        guard !newLiteral.isEmpty else { return }
        
        Task {
            await filtersTracker.addFilteredLiteral(newLiteral)
            newLiteral = ""
        }
    }
    
    func deleteLiteral(_ literal: String) {
        guard filtersTracker.literals.contains(literal) else {
            return
        }
        
        Task {
            await filtersTracker.removeFilteredLiteral(literal)
        }
    }
}
