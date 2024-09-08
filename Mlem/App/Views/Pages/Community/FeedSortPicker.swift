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
        case alwaysAvailable, availableOnInstance, communityAndPersonSearchable
    }
    
    @Environment(AppState.self) var appState
    
    let filters: Set<Filter>
    @Binding var sort: ApiSortType
    
    init(sort: Binding<ApiSortType>, filters: Set<Filter> = []) {
        self._sort = sort
        self.filters = filters
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
        }), filters: [.availableOnInstance])
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
        .disabled(filters.contains(.availableOnInstance) && appState.firstApi.fetchedVersion == nil)
    }
    
    @ViewBuilder
    func itemLabels(_ collection: [ApiSortType]) -> some View {
        ForEach(collection.filter { sortType in
            filters.allSatisfy { filter in
                switch filter {
                case .alwaysAvailable: sortType.minimumVersion == .zero
                case .availableOnInstance:
                    (appState.firstApi.fetchedVersion ?? .infinity) >= sortType.minimumVersion
                case .communityAndPersonSearchable:
                    ApiSortType.communityAndPersonSearchCases.contains(sortType)
                }
            }
        }, id: \.self) { item in
            Label(String(localized: item.label), systemImage: item.systemImage)
        }
    }
}
