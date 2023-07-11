//
//  Filters.swift
//  Mlem
//
//  Created by David Bureš on 07.05.2023.
//

import SwiftUI

struct FiltersSettingsView: View {

    @EnvironmentObject var filtersTracker: FiltersTracker
    @EnvironmentObject var appState: AppState

    @State private var newFilteredKeyword: String = ""
    @State private var isShowingKeywordImporter: Bool = false

    @State private var isShowingFilterDeletionConfirmation: Bool = false

    var body: some View {
        List {
            Section {
                ForEach(filtersTracker.filteredKeywords, id: \.self) { filteredKeyword in
                    Text(filteredKeyword)
                }
                .onDelete(perform: deleteKeyword)

                HStack(alignment: .center) {
                    TextField("Add Keyword…", text: $newFilteredKeyword, prompt: Text("Add Keyword…"))

                    Spacer()

                    Button {
                        addKeyword(newFilteredKeyword)
                    } label: {
                        Text("Add")
                    }
                    .disabled(newFilteredKeyword.isEmpty)

                }
            } header: {
                Text("Filtered Keywords")
            } footer: {
                Text("Posts containing these keywords in their title will not be shown")
            }

            Section {
                Button {
                    showShareSheet(URLtoShare: AppConstants.filteredKeywordsFilePath)
                } label: {
                    Label("Export filters", systemImage: "square.and.arrow.up")
                }
                .disabled(filtersTracker.filteredKeywords.isEmpty)

                Button {
                    isShowingKeywordImporter = true
                } label: {
                    Label("Import filters", systemImage: "square.and.arrow.down")
                }
                .fileImporter(isPresented: $isShowingKeywordImporter, allowedContentTypes: [.json]) { result in
                    do {
                        let urlOfImportedFile: URL = try result.get()

                        defer { urlOfImportedFile.stopAccessingSecurityScopedResource() }
                        guard urlOfImportedFile.startAccessingSecurityScopedResource() else {
                            return
                        }

                        print("URL of imported file: \(urlOfImportedFile)")
                        do {
                            let decodedKeywords = try decodeFromFile(
                                fromURL: urlOfImportedFile,
                                whatToDecode: .filteredKeywords
                            ) as? [String] ?? []

                            urlOfImportedFile.stopAccessingSecurityScopedResource()

                            print("Decoded these: \(decodedKeywords)")

                            withAnimation {
                                filtersTracker.filteredKeywords = decodedKeywords
                            }
                        } catch let decodingError {
                            appState.contextualError = .init(
                                title: "Couldn't decode blocklist",
                                message: "Try again. If the problem keeps happening, try reinstalling Mlem.",
                                underlyingError: decodingError
                            )
                            
                            print("Failed while decoding blocklist: \(decodingError)")
                        }

                    } catch let blocklistImportingError {
                        appState.contextualError = .init(
                            title: "Couldn't find blocklist",
                            message: """
                                     If you are trying to read it from iCloud, make sure your internet is working. \
                                     Otherwise, try moving the blocklist file to another location.
                                     """,
                            underlyingError: blocklistImportingError
                        )
                        print("Failed while reading file: \(blocklistImportingError)")
                    }
                }

            }

            Section {
                Button(role: .destructive) {
                    isShowingFilterDeletionConfirmation = true
                } label: {
                    Label("Delete all filters", systemImage: "trash")
                        .foregroundColor(.red)
                }
                .confirmationDialog(
                    "Are you sure you want to delete all your filters?",
                    isPresented: $isShowingFilterDeletionConfirmation,
                    titleVisibility: .visible) {
                        Button(role: .destructive) {
                            isShowingFilterDeletionConfirmation = false
                            withAnimation {
                                filtersTracker.filteredKeywords = .init()
                                filtersTracker.filteredUsers = .init()
                            }
                        } label: {
                            Text("Delete \(filtersTracker.filteredKeywords.count + filtersTracker.filteredUsers.count) filters")
                        }

                        Button(role: .cancel) {
                            isShowingFilterDeletionConfirmation = false
                        } label: {
                            Text("Cancel")
                        }
                    } message: {
                        Text(
                             """
                             You are about to delete \(filtersTracker.filteredKeywords.count + filtersTracker.filteredUsers.count) filters.
                             You cannot undo this action.
                             """
                        )
                    }

            }
        }
        .navigationTitle("Filters")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .automatic) {
                EditButton()
                    .disabled(filtersTracker.filteredKeywords.isEmpty && filtersTracker.filteredUsers.isEmpty)
            }
        }
    }

    func addKeyword(_ newKeyword: String) {
        if !newKeyword.isEmpty {
            if filtersTracker.filteredKeywords.contains(newKeyword) { /// If the word is already in there, just move it to the top
                let indexOfPreviousOccurence: Int = filtersTracker.filteredKeywords.firstIndex(where: { $0 == newKeyword })!
                withAnimation {
                    filtersTracker.filteredKeywords.move(from: indexOfPreviousOccurence, to: 0)
                }
            } else {
                withAnimation {
                    filtersTracker.filteredKeywords.prepend(newKeyword)
                }
            }

            newFilteredKeyword = ""
        }
    }
    func deleteKeyword(at offsets: IndexSet) {
        filtersTracker.filteredKeywords.remove(atOffsets: offsets)
    }
}
