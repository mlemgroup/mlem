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
    @Environment(AppState.self) var appState
    @Environment(NavigationLayer.self) var navigation
    
    @Binding var sort: ApiSortType
    
    @State var topSortPopupPresented: Bool = false
    
    init(sort: Binding<ApiSortType>) {
        self._sort = sort
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
        }))
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
        Menu(sort.label(topFormat: topSortTypes.count == 1 ? .topOnly : .topAndTimescale), systemImage: sort.systemImage) {
            Section {
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
        .disabled(appState.firstApi.fetchedVersion == nil)
        .popover(isPresented: $topSortPopupPresented) {
            TopSortPicker(selected: $sort)
                // This background is always drawn over a material background unfortunately,
                // meaning that we can't use thin materials
                .presentationBackground(.clear)
                .presentationCornerRadius(18)
                .presentationCompactAdaptation(.popover)
        }
    }
}
