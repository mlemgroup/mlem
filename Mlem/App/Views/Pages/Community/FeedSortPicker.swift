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
        case alwaysAvailable, availableOnInstance, communitySearchable, personSearchable
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
        let topModes = filterSortModes(ApiSortType.topCases)
        Menu(sort.fullLabel(shortTopMode: topModes.count == 1), systemImage: sort.systemImage) {
            Picker("Sort", selection: $sort) {
                itemLabels(filterSortModes(ApiSortType.nonTopCases))
                if topModes.count == 1, let first = topModes.first {
                    Label("Top", systemImage: Icons.topSort)
                        .tag(first)
                } else {
                    Picker("Top...", systemImage: Icons.topSort, selection: $sort) {
                        itemLabels(topModes)
                    }
                    .pickerStyle(.menu)
                }
            }
        }
        .disabled(filters.contains(.availableOnInstance) && appState.firstApi.fetchedVersion == nil)
    }
    
    @ViewBuilder
    func itemLabels(_ collection: [ApiSortType]) -> some View {
        ForEach(collection, id: \.self) { item in
            Label(String(localized: item.label), systemImage: item.systemImage)
        }
    }
    
    private func filterSortModes(_ collection: any Collection<ApiSortType>) -> [ApiSortType] {
        collection.filter { sortType in
            filters.allSatisfy { filter in
                switch filter {
                case .alwaysAvailable: sortType.minimumVersion == .zero
                case .availableOnInstance:
                    (appState.firstApi.fetchedVersion ?? .infinity) >= sortType.minimumVersion
                case .communitySearchable:
                    ApiSortType.communitySearchCases.contains(sortType)
                case .personSearchable:
                    ApiSortType.personSearchCases.contains(sortType)
                }
            }
        }
    }
}
