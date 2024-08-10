//
//  FeedSortPicker.swift
//  Mlem
//
//  Created by Sjmarf on 10/08/2024.
//

import MlemMiddleware
import SwiftUI

struct FeedSortPicker: View {
    @Environment(AppState.self) var appState
    
    @Binding var sort: ApiSortType
    
    init(sort: Binding<ApiSortType>) {
        self._sort = sort
    }
    
    init(feedLoader: CorePostFeedLoader) {
        self.init(sort: .init(get: { feedLoader.sortType }, set: { newSort in
            Task {
                do {
                    try await feedLoader.changeSortType(to: newSort, forceRefresh: true)
                } catch {
                    handleError(error)
                }
            }
        }))
    }
    
    var body: some View {
        Menu("Sort by: \(String(localized: sort.label))", systemImage: sort.systemImage) {
            if let instanceVersion = appState.firstApi.fetchedVersion {
                Picker("Sort", selection: $sort) {
                    ForEach(ApiSortType.nonTopCases.filter { instanceVersion >= $0.minimumVersion }, id: \.self) { item in
                        Label(String(localized: item.label), systemImage: item.systemImage)
                    }
                }
                .pickerStyle(.inline)
                Picker("Top...", systemImage: Icons.topSort, selection: $sort) {
                    ForEach(ApiSortType.topCases.filter { instanceVersion >= $0.minimumVersion }, id: \.self) { item in
                        Label(String(localized: item.label), systemImage: item.systemImage)
                    }
                }
                .pickerStyle(.menu)
            }
        }
    }
}
