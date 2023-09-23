//
//  SearchRoot.swift
//  Mlem
//
//  Created by Sjmarf on 23/09/2023.
//

import SwiftUI

struct SearchRoot: View {
    
    @Environment(\.tabSelectionHashValue) private var selectedTagHashValue
    @Environment(\.tabNavigationSelectionHashValue) private var selectedNavigationTabHashValue
    @StateObject private var searchRouter: NavigationRouter<NavigationRoute> = .init()
    
    @StateObject var searchModel: SearchModel = .init()
    @StateObject var contentTracker: ContentTracker<AnyContentModel> = .init()
    @EnvironmentObject private var recentSearchesTracker: RecentSearchesTracker
    
    var body: some View {
        NavigationStack(path: $searchRouter.path) {
            SearchView()
                .environmentObject(searchModel)
                .environmentObject(contentTracker)
                .searchable(
                    text: $searchModel.searchText,
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: "Search for communities & users"
                )
                .autocorrectionDisabled(true)
                .textInputAutocapitalization(.never)
                .onReceive(
                    searchModel.$searchText
                        .debounce(for: .seconds(0.2), scheduler: DispatchQueue.main)
                ) { _ in
                    if searchModel.previousSearchText != searchModel.searchText {
                        if !searchModel.searchText.isEmpty {
                            contentTracker.refresh(using: searchModel.performSearch)
                        }
                    }
                }

                .onChange(of: searchModel.searchTab) { newValue in
                    switch newValue {
                    case .topResults:
                        if let communities = searchModel.firstPageCommunities, let users = searchModel.firstPageUsers {
                            contentTracker.replaceAll(with: searchModel.combineResults(communities: communities, users: users))
                            return
                        }
                    case .communities:
                        if let communities = searchModel.firstPageCommunities {
                            contentTracker.replaceAll(with: communities)
                            return
                        }
                    case .users:
                        if let users = searchModel.firstPageUsers {
                            contentTracker.replaceAll(with: users)
                            return
                        }
                    }
                    contentTracker.refresh(using: searchModel.performSearch)
                }
                .onAppear {
                    Task(priority: .background) {
                        if !recentSearchesTracker.hasLoaded {
                            try await recentSearchesTracker.loadRecentSearches()
                        }
                    }
                    contentTracker.refresh(using: searchModel.performSearch)
                }
        }
        .handleLemmyLinkResolution(navigationPath: .constant(searchRouter))
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
}
