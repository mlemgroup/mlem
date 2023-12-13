//
//  FiltersSettingsView.swift
//  Mlem
//
//  Created by David Bureš on 07.05.2023.
//

import Dependencies
import SwiftUI

struct FiltersSettingsView: View {
    @AppStorage("showSettingsIcons") var showSettingsIcons: Bool = true
    
    @Dependency(\.errorHandler) var errorHandler
    @Dependency(\.persistenceRepository) var persistenceRepository
    
    @EnvironmentObject var filtersTracker: FiltersTracker

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
                Text("Posts containing these keywords in their title will not be shown.")
            }

            Section {
                if !filtersTracker.filteredKeywords.isEmpty {
                    ShareLink(item: persistenceRepository.getFilteredKeywordsPath())
                }

                Button {
                    isShowingKeywordImporter = true
                } label: {
                    Label {
                        Text("Import Filters")
                    } icon: {
                        if showSettingsIcons {
                            Image(systemName: Icons.import)
                        }
                    }
                }
                .fileImporter(isPresented: $isShowingKeywordImporter, allowedContentTypes: [.json]) { result in
                    do {
                        let urlOfImportedFile: URL = try result.get()

                        defer { urlOfImportedFile.stopAccessingSecurityScopedResource() }
                        guard urlOfImportedFile.startAccessingSecurityScopedResource() else {
                            return
                        }

                        do {
                            let data = try Data(contentsOf: urlOfImportedFile, options: .mappedIfSafe)
                            let keywords = try JSONDecoder().decode([String].self, from: data)
                            withAnimation {
                                filtersTracker.filteredKeywords = keywords
                            }
                        } catch let decodingError {
                            errorHandler.handle(
                                .init(
                                    title: "Couldn't decode blocklist",
                                    message: "Try again. If the problem keeps happening, try reinstalling Mlem.",
                                    underlyingError: decodingError
                                )
                            )
                        }

                    } catch let blocklistImportingError {
                        errorHandler.handle(
                            .init(
                                title: "Couldn't find blocklist",
                                message: """
                                If you are trying to read it from iCloud, make sure your internet is working. \
                                Otherwise, try moving the blocklist file to another location.
                                """,
                                underlyingError: blocklistImportingError
                            )
                        )
                    }
                }
            }

            Section {
                Button(role: .destructive) {
                    isShowingFilterDeletionConfirmation = true
                } label: {
                    Label {
                        Text("Delete All Filters")
                    } icon: {
                        if showSettingsIcons {
                            Image(systemName: Icons.delete)
                        }
                    }
                    .foregroundColor(.red)
                    .opacity(filtersTracker.filteredKeywords.isEmpty ? 0.6 : 1)
                }
                .disabled(filtersTracker.filteredKeywords.isEmpty)
                .confirmationDialog(
                    "Are you sure you want to delete all filters?",
                    isPresented: $isShowingFilterDeletionConfirmation,
                    titleVisibility: .visible
                ) {
                    Button(role: .destructive) {
                        isShowingFilterDeletionConfirmation = false
                        withAnimation {
                            filtersTracker.filteredKeywords = .init()
                        }
                    } label: {
                        Text("Delete \(filtersTracker.filteredKeywords.count) filters")
                    }

                    Button(role: .cancel) {
                        isShowingFilterDeletionConfirmation = false
                    } label: {
                        Text("Cancel")
                    }
                } message: {
                    Text(
                        """
                        You are about to delete \(filtersTracker.filteredKeywords.count) filters.
                        You cannot undo this action.
                        """
                    )
                }
            }
        }
        .fancyTabScrollCompatible()
        .navigationTitle("Filters")
        .navigationBarColor()
        .navigationBarTitleDisplayMode(.inline)
        .hoistNavigation()
        .toolbar {
            ToolbarItem(placement: .automatic) {
                EditButton()
                    .disabled(filtersTracker.filteredKeywords.isEmpty)
            }
        }
    }

    func addKeyword(_ newKeyword: String) {
        if !newKeyword.isEmpty {
            // If the word is already in there, just move it to the top
            if filtersTracker.filteredKeywords.contains(newKeyword.lowercased()) {
                let indexOfPreviousOccurence: Int = filtersTracker.filteredKeywords.firstIndex(where: { $0 == newKeyword })!
                withAnimation {
                    filtersTracker.filteredKeywords.move(from: indexOfPreviousOccurence, to: 0)
                }
            } else {
                withAnimation {
                    filtersTracker.filteredKeywords.prepend(newKeyword.lowercased())
                }
            }

            newFilteredKeyword = ""
        }
    }

    func deleteKeyword(at offsets: IndexSet) {
        filtersTracker.filteredKeywords.remove(atOffsets: offsets)
    }
}
