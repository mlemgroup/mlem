//
//  Search View.swift
//  Mlem
//
//  Created by Jake Shirley on 7/5/23.
//

import Dependencies
import Foundation
import UIKit
import SwiftUI

struct SearchView: View {
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.errorHandler) var errorHandler
    @Dependency(\.hapticManager) var hapticManager
    
    @StateObject var searchModel: SearchModel = .init()
    @StateObject var contentTracker: ContentTracker<CommunityModel> = .init()
    
    // environment
    @Environment(\.tabSelectionHashValue) private var selectedTagHashValue
    @Environment(\.tabNavigationSelectionHashValue) private var selectedNavigationTabHashValue
    @Environment(\.isSearching) private var isSearching
    
    // private state
    @State private var shouldLoad: Bool = false
    
    @StateObject private var searchRouter: NavigationRouter<NavigationRoute> = .init()
    @State private var selectedColorIndex = 0
    
    func performSearch(page: Int) async throws -> [CommunityModel] {
        let response = try await apiClient.performSearch(
            query: searchModel.searchText,
            searchType: .communities,
            sortOption: .topAll,
            listingType: .all,
            page: page,
            limit: 30
        )
        return response.communities.map { CommunityModel(from: $0) }
    }

    var body: some View {
        NavigationStack(path: $searchRouter.path) {
            content
                .handleLemmyViews()
                .navigationBarTitleDisplayMode(.large)
                .navigationBarColor()
                .navigationTitle("Search")
        }
        .handleLemmyLinkResolution(navigationPath: .constant(searchRouter))
        .searchable(text: $searchModel.searchText, prompt: "Search for communities")
        .autocorrectionDisabled(true)
        .textInputAutocapitalization(.never)
        .onChange(of: searchModel.searchText) { _ in
            contentTracker.refresh(with: performSearch)
        }
//        .onSubmit(of: .search) {
//
//        }
        .onChange(of: selectedTagHashValue) { newValue in
            if newValue == TabSelection.search.hashValue {
                print("switched to Search tab")
            }
        }
        .onChange(of: selectedNavigationTabHashValue) { newValue in
            if newValue == TabSelection.search.hashValue {
                print("re-selected \(TabSelection.search) tab")
            }
        }
    }
    
    @ViewBuilder
    private var content: some View {
        ScrollView {
            VStack(spacing: 0) {
                ScrollView(.horizontal) {
                    SearchTabPicker(selected: $searchModel.searchTab)
                        .padding(.horizontal)
                }
                .scrollIndicators(.hidden)
                .padding(.vertical, 4)
                Divider()
                    .padding(.top, 18)
                LazyVStack(spacing: 0) {
                    ForEach(contentTracker.items, id: \.communityId) { community in
                        CommunityResultView(community: community)
                            .onAppear {
                                if contentTracker.shouldLoadContentAfter(after: community) {
                                    shouldLoad = true
                                }
                            }
                        Divider()
                    }
                    VStack {
                        if contentTracker.isLoading {
                            ProgressView()
                        } else if contentTracker.hasReachedEnd {
                            HStack {
                                Image(systemName: "figure.climbing")
                                Text("I think I've found the bottom!")
                            }
                            .foregroundColor(.secondary)
                        }
                    }
                    .frame(height: 100)
                }

            }
        }
        .fancyTabScrollCompatible()
        .environmentObject(contentTracker)
        .onChange(of: shouldLoad) { value in
            if value {
                print("Loading page \(contentTracker.page + 1)...")
                Task(priority: .medium) { try await contentTracker.loadNextPage() }
            }
            shouldLoad = false
        }
    }
}
