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
    
    @ViewBuilder let content: ([Item], NavigationLayer) -> Content
    let api: ApiClient
    let filter: ListingType
    
    @State var query: String = ""
    @State var results: [Item] = []
    
    /// If `api` is `nil`, the active ApiClient will be used.
    init(
        api: ApiClient? = nil,
        filter: ListingType? = nil,
        @ViewBuilder content: @escaping ([Item], NavigationLayer) -> Content
    ) {
        self.api = api ?? AppState.main.firstApi
        self.filter = filter ?? .all
        self.content = content
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                content(results, navigation)
            }
        }
        .background(.themedGroupedBackground)
        .presentationBackground(.themedGroupedBackground)
        .navigationBarTitleDisplayMode(.inline)
        .withSheetSearch(query: $query)
        .task(id: query, priority: .userInitiated) {
            do {
                if !query.isEmpty {
                    try await Task.sleep(for: .seconds(0.2))
                }
                let response = try await Item.search(
                    api: api,
                    query: query,
                    pageInfo: .init(cursor: .first, limit: 20),
                    filter: filter,
                    hostApi: appState.firstApi
                )
                Task { @MainActor in
                    results = response.items
                }
            } catch {
                handleError(error)
            }
        }
    }
}

extension SearchSheetView {
    init<RowContent: View>(
        api: ApiClient? = nil,
        filter: ListingType? = nil,
        @ViewBuilder content: @escaping (Item, NavigationLayer) -> RowContent
    ) where Content == SearchResultsView<Item, RowContent> {
        self.api = api ?? AppState.main.firstApi
        self.filter = filter ?? .all
        self.content = { (results: [Item], navigation: NavigationLayer) in
            SearchResultsView(results: results) { item in
                content(item, navigation)
            }
        }
    }
    
    init<RowContent: View, HeaderContent: View>(
        api: ApiClient? = nil,
        filter: ListingType? = nil,
        @ViewBuilder content: @escaping (Item, NavigationLayer) -> RowContent,
        @ViewBuilder header: @escaping () -> HeaderContent
    ) where Content == VStack<TupleView<(HeaderContent, SearchResultsView<Item, RowContent>)>> {
        self.api = api ?? AppState.main.firstApi
        self.filter = filter ?? .all
        self.content = { (results: [Item], dismiss: NavigationLayer) in
            VStack(alignment: .leading, spacing: 0) {
                header()
                SearchResultsView(results: results) { item in
                    content(item, dismiss)
                }
            }
        }
    }
}
