//
//  FeedSortPicker.swift
//  Mlem
//
//  Created by Sjmarf on 10/08/2024.
//

import Flow
import MlemMiddleware
import SwiftUI

struct FeedSortPicker: View {
    enum Filter {
        case alwaysAvailable, availableOnInstance, communitySearchable, personSearchable
    }
    
    @Environment(AppState.self) var appState
    @Environment(NavigationLayer.self) var navigation
    
    let filters: Set<Filter>
    @Binding var sort: ApiSortType
    
    @State var topSortPopupPresented: Bool = false
    
    init(sort: Binding<ApiSortType>, filters: Set<Filter> = []) {
        self._sort = sort
        self.filters = filters
    }
    
    init(feedLoader: CorePostFeedLoader) {
        self.init(sort: .init(get: { feedLoader.sortType }, set: { newSort in
            Task { @MainActor in
                do {
                    try await feedLoader.changeSortType(to: newSort, forceRefresh: false)
                } catch {
                    handleError(error)
                }
            }
        }), filters: [.availableOnInstance])
    }
    
    var nonTopSortTypes: [ApiSortType] {
        ApiSortType.nonTopCases
            .filter { PinnedSortTracker.main.pinnedSortTypes.contains($0) }
            .filter { (appState.firstApi.fetchedVersion ?? .infinity) >= $0.minimumVersion }
    }
    
    var topSortTypes: [ApiSortType] {
        ApiSortType.topCases
            .filter { PinnedSortTracker.main.pinnedSortTypes.contains($0) }
            .filter { (appState.firstApi.fetchedVersion ?? .infinity) >= $0.minimumVersion }
    }
    
    var body: some View {
        let topModes = filterSortModes(ApiSortType.topCases)
        Menu(sort.label(topFormat: topModes.count == 1 ? .topOnly : .topAndTimescale), systemImage: sort.systemImage) {
            Section("Sort by...") {
                ForEach(nonTopSortTypes, id: \.self) { type in
                    Toggle(
                        type.label(),
                        systemImage: type.systemImage,
                        isOn: .init(get: { sort == type }, set: { _ in sort = type })
                    )
                }
                let topSortTypes = topSortTypes
                if topSortTypes.count > 3 {
                    Toggle(
                        "Top...",
                        systemImage: Icons.topSort,
                        isOn: .init(get: { ApiSortType.topCases.contains(sort) }, set: { _ in topSortPopupPresented = true })
                    )
                } else {
                    ForEach(topSortTypes, id: \.self) { type in
                        Toggle(
                            type.label(topFormat: .topAndTimescale),
                            systemImage: type.systemImage,
                            isOn: .init(get: { sort == type }, set: { _ in sort = type })
                        )
                    }
                }
            }
            Section {
                Button("More...", systemImage: Icons.menuCircle) {
                    navigation.openSheet(.advancedSorting($sort))
                }
            }
        }
        .disabled(filters.contains(.availableOnInstance) && appState.firstApi.fetchedVersion == nil)
        .popover(isPresented: $topSortPopupPresented) {
            TopSortPicker(selected: $sort)
                // This background is always drawn over a material background unfortunately,
                // meaning that we can't use thin materials
                .presentationBackground(.clear)
                .presentationCornerRadius(18)
                .presentationCompactAdaptation(.popover)
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
