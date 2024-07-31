//
//  SearchSheetView.swift
//  Mlem
//
//  Created by Sjmarf on 27/06/2024.
//

import Combine
import MlemMiddleware
import SwiftUI

struct SearchSheetView<Item: Searchable, Content: View>: View {
    @Environment(AppState.self) var appState
    @Environment(\.dismiss) var dismiss
    
    enum CloseButtonLabel: String {
        case cancel, done
    }
    
    @ViewBuilder let content: ([Item], DismissAction) -> Content
    let closeButtonLabel: CloseButtonLabel
    
    @State var query: String = ""
    @State var results: [Item] = []
    
    @State var editing: Bool = true
    @State var focused: Bool = true
    
    init(
        closeButtonLabel: CloseButtonLabel = .cancel,
        @ViewBuilder content: @escaping ([Item], DismissAction) -> Content
    ) {
        self.content = content
        self.closeButtonLabel = closeButtonLabel
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                content(results, dismiss)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack(spacing: 0) {
                    SearchBar("Search", text: $query, isEditing: $editing)
                        .isInitialFirstResponder(true)
                        .focused($focused)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(closeButtonLabel.rawValue.capitalized) {
                    dismiss()
                }
            }
        }
        .task(id: query, priority: .userInitiated) {
            do {
                if !query.isEmpty {
                    try await Task.sleep(for: .seconds(0.2))
                }
                let response = try await Item.search(
                    api: appState.firstApi,
                    query: query,
                    page: 1,
                    limit: 20
                )
                Task { @MainActor in
                    results = response
                }
            } catch {
                handleError(error)
            }
        }
    }
}

extension SearchSheetView {
    init<Content2: View>(
        closeButtonLabel: CloseButtonLabel = .cancel,
        @ViewBuilder content: @escaping (Item, DismissAction) -> Content2
    ) where Content == SearchResultsView<Item, Content2> {
        self.closeButtonLabel = closeButtonLabel
        self.content = { (results: [Item], dismiss: DismissAction) in
            SearchResultsView(results: results) { item in
                content(item, dismiss)
            }
        }
    }
}
