//
//  FiltersSettingsView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-12-22.
//

import Dependencies
import SwiftUI
import os

struct FiltersSettingsView: View {
    @Setting(\.filters_keywordFilterEnabled) var keywordFilterEnabled
    @Setting(\.filters_literalFilterEnabled) var literalFilterEnabled
    
    @Environment(FiltersTracker.self) var filtersTracker
    @Environment(NavigationLayer.self) var navigation
    
    @State var newKeyword: String = ""
    @State var newLiteral: String = ""
    
    @State var legacyWarningDisplayed: Bool = false
    
    var headerDescription: String {
        var output = String(localized: "Hide posts containing certain words, phrases, or character sequences from your feed.")
        if AccountsTracker.main.highestLevelAccountType >= .moderator {
            output += " "
            // swiftlint:disable:next line_length
            output += String(localized: "If you are a moderator or administrator of a filtered post, it will appear in your feed but require you to tap to view its content.")
        }
        return output
    }
    
    var body: some View {
        Form {
            SettingsHeaderView(
                title: "Filters",
                description: headerDescription,
                icon: .settings.keywordFilter
            )
            
            Section("Keywords") {
                keywordSection
            } footer: {
                // swiftlint:disable:next line_length
                Text("Hide posts with titles containing these whole words or phrases. Ignores case and punctuation (e.g., the keyword \"john\" will also filter \"John's\").")
            }
            
            Section("Literals") {
                literalSection
            } footer: {
                Text("Hide posts with titles containing containing these precise character sequences.")
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .withConditionalLabelStyle()
        .navigationTitle("Filters")
        .versionAwareDialog("Deprecated Format", isPresented: $legacyWarningDisplayed) {
            Button("Re-Export") { export() }
            Button("Close", role: .cancel) {}
        } message: {
            // swiftlint:disable:next line_length
            Text("These filters were saved by an older version of Mlem, and will not be compatible with future versions. To preserve compatibility, re-export your filters.")
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu("More...", icon: .general.toolbarMenu) {
                    Button("Export...", icon: .general.export) { export() }
                    Button("Import...", icon: .general.import) {
                        navigation.showFilePicker(types: [.plainText, .json]) { data in
                            do {
                                let jsonData = try JSONDecoder().decode(ExportableFilters.self, from: data)
                                Task { @MainActor in
                                    await filtersTracker.resetFilteredKeywords(to: jsonData.rawKeywords)
                                    filtersTracker.resetFilteredLiterals(to: jsonData.literals)
                                }
                            } catch {
                                // TODO: Mlem 2.5 remove legacy compatibility
                                let text = String(data: data, encoding: .utf8) ?? ""
                                await filtersTracker.resetFilteredKeywords(
                                    to: Set(text.split(separator: "\n").map(String.init))
                                )
                                legacyWarningDisplayed = true
                            }
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    var keywordSection: some View {
        Toggle("Enable", icon: .settings.keywordFilter, isOn: $keywordFilterEnabled)
        
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
        Toggle("Enable", icon: .settings.keywordFilter, isOn: $literalFilterEnabled)
        
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
    
    func export() {
        do {
            let jsonData = try JSONEncoder().encode(ExportableFilters(
                rawKeywords: filtersTracker.rawKeywords,
                literals: filtersTracker.literals))
            
            Task {
                if let jsonString = String(data: jsonData, encoding: .utf8), let url = await downloadTextToFileSystem(
                    fileName: "filters.json",
                    text: jsonString) {
                    navigation.model?.shareInfo = .init(url: url)
                } else {
                    ToastModel.main.add(.failure())
                }
            }
        } catch {
            handleError(error)
        }
    }
}

private struct ExportableFilters: Codable {
    let rawKeywords: Set<String>
    let literals: Set<String>
}
