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
    @Environment(NavigationLayer.self) var navigation
    @Environment(Palette.self) var palette
    
    enum CloseButtonLabel: String {
        case cancel, done
    }
    
    @ViewBuilder let content: ([Item], NavigationLayer) -> Content
    let api: ApiClient
    let closeButtonLabel: CloseButtonLabel
    
    @State var query: String = ""
    @State var results: [Item] = []
    
    @State var editing: Bool = true
    @State var focused: Bool = true
    
    /// If `api` is `nil`, the active ApiClient will be used.
    init(
        api: ApiClient? = nil,
        closeButtonLabel: CloseButtonLabel = .cancel,
        @ViewBuilder content: @escaping ([Item], NavigationLayer) -> Content
    ) {
        self.api = api ?? AppState.main.firstApi
        self.content = content
        self.closeButtonLabel = closeButtonLabel
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                content(results, navigation)
            }
        }
        .background(palette.background)
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
                    navigation.dismissSheet()
                }
            }
        }
        .task(id: query, priority: .userInitiated) {
            do {
                if !query.isEmpty {
                    try await Task.sleep(for: .seconds(0.2))
                }
                let response = try await Item.search(
                    api: api,
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
        .onAppear {
            focused = true
        }
    }
}

extension SearchSheetView {
    init<Content2: View>(
        api: ApiClient? = nil,
        closeButtonLabel: CloseButtonLabel = .cancel,
        @ViewBuilder content: @escaping (Item, NavigationLayer) -> Content2
    ) where Content == SearchResultsView<Item, Content2> {
        self.api = api ?? AppState.main.firstApi
        self.closeButtonLabel = closeButtonLabel
        self.content = { (results: [Item], navigation: NavigationLayer) in
            SearchResultsView(results: results) { item in
                content(item, navigation)
            }
        }
    }
}
