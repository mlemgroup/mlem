//
//  FeedSortPicker.swift
//  Mlem
//
//  Created by Sjmarf on 10/08/2024.
//

import MlemMiddleware
import SwiftUI

struct FeedSortPicker: View {
    enum Filter {
        case all, alwaysAvailable, availableOnInstance
    }
    
    @Environment(AppState.self) var appState
    
    let filter: Filter
    @Binding var sort: ApiSortType
    
    init(sort: Binding<ApiSortType>, showing filter: Filter = .all) {
        self._sort = sort
        self.filter = filter
    }
    
    init(feedLoader: CorePostFeedLoader) {
        self.init(sort: .init(get: { feedLoader.sortType }, set: { newSort in
            Task {
                do {
                    try await feedLoader.changeSortType(to: newSort, forceRefresh: false)
                } catch {
                    handleError(error)
                }
            }
        }), showing: .availableOnInstance)
    }
    
    var body: some View {
        Menu(sort.fullLabel, systemImage: sort.systemImage) {
            Picker("Sort", selection: $sort) {
                itemLabels(ApiSortType.nonTopCases)
                Picker("Top...", systemImage: Icons.topSort, selection: $sort) {
                    itemLabels(ApiSortType.topCases)
                }
                .pickerStyle(.menu)
            }
        }
        .disabled(filter == .availableOnInstance && appState.firstApi.fetchedVersion == nil)
    }
    
    @ViewBuilder
    func itemLabels(_ collection: [ApiSortType]) -> some View {
        ForEach(collection.filter {
            switch filter {
            case .all: true
            case .alwaysAvailable: $0.minimumVersion == .zero
            case .availableOnInstance:
                (appState.firstApi.fetchedVersion ?? .infinity) >= $0.minimumVersion
            }
        }, id: \.self) { item in
            Label(String(localized: item.label), systemImage: item.systemImage)
        }
    }
}
