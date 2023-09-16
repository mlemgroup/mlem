//
//  Search View.swift
//  Mlem
//
//  Created by Jake Shirley on 7/5/23.
//

import Dependencies
import Foundation
import SwiftUI

struct SearchView: View {
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.errorHandler) var errorHandler
    
    @Namespace var scrollToTop
    
    // environment
    @EnvironmentObject var communitySearchResultsTracker: CommunitySearchResultsTracker
    @EnvironmentObject var recentSearchesTracker: RecentSearchesTracker

    @Environment(\.tabSelectionHashValue) private var selectedTagHashValue
    @Environment(\.tabNavigationSelectionHashValue) private var selectedNavigationTabHashValue
    @Environment(\.dismiss) private var dismiss
    
    // private state
    @State private var isSearching: Bool = false
    @State private var lastSearchedText: String = ""
    @State private var showRecentSearches: Bool = true
    @State private var searchTask: Task<Void, Never>?
    @State private var searchText: String = ""
    
    @State private var searchPage: Int = 1
    @State private var hasMorePages: Bool = true
    
    @State private var scrollToTopAppeared = false
    
    @StateObject private var searchRouter: NavigationRouter<NavigationRoute> = .init()
    @StateObject private var navigation: Navigation = .init()

    // constants
    private let searchPageSize = 50

    var body: some View {
        NavigationStack(path: $searchRouter.path) {
            content
                .tabBarNavigationEnabled(.search, navigation)
                .handleLemmyViews()
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarColor()
                .navigationTitle("Search")
        }
        .environment(\.navigationPathWithRoutes, $searchRouter.path)
        .environmentObject(navigation)
        .handleLemmyLinkResolution(navigationPath: .constant(searchRouter))
        .searchable(text: getSearchTextBinding(), prompt: "Search for communities")
        .autocorrectionDisabled(true)
        .textInputAutocapitalization(.never)
        .onSubmit(of: .search) {
            performSearch()
        }
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
        if showRecentSearches {
            recentSearches
        } else {
            searchedContents
        }
    }
    
    @ViewBuilder
    private var recentSearches: some View {
        ScrollViewReader { proxy in
            List {
                ListScrollToView(appeared: $scrollToTopAppeared)
                    .id(scrollToTop)
                
                Section {
                    ForEach(recentSearchesTracker.recentSearches, id: \.self) { recentlySearchedText in
                        Button(recentlySearchedText) {
                            searchText = recentlySearchedText
                            performSearch()
                        }
                    }
                } header: {
                    Text(recentSearchesTracker.recentSearches.isEmpty ? "No recent searches" : "Recent searches")
                }
                
                Button(role: .destructive) {
                    recentSearchesTracker.clearRecentSearches()
                } label: {
                    HStack {
                        Spacer()
                        Text("Clear recent searches")
                            .foregroundColor(.red)
                        Spacer()
                    }
                }
            }
            .listStyle(.insetGrouped)
            .hoistNavigation(
                dismiss: dismiss,
                auxiliaryAction: {
                    withAnimation {
                        proxy.scrollTo(scrollToTop, anchor: .bottom)
                    }
                    return true
                }
            )
        }
    }
    
    @ViewBuilder
    private var searchedContents: some View {
        if isSearching, communitySearchResultsTracker.foundCommunities.isEmpty {
            LoadingView(whatIsLoading: .search)
        } else if communitySearchResultsTracker.foundCommunities.isEmpty {
            Text("No communities found for search")
        } else {
            ScrollViewReader { proxy in
                List {
                    ListScrollToView(appeared: $scrollToTopAppeared)
                        .id(scrollToTop)
                    
                    ForEach(communitySearchResultsTracker.foundCommunities) { community in
                        CommunityLinkView(
                            community: community.community,
                            extraText: "\(community.counts.subscribers.roundedWithAbbreviations) subscribers"
                        )
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .onAppear {
                            let communityIndex = communitySearchResultsTracker.foundCommunities.firstIndex(of: community)
                            if let index = communityIndex {
                                // If we are half a page from the end, ask for more
                                let distanceFromEnd = communitySearchResultsTracker.foundCommunities.count - index
                                if distanceFromEnd == searchPageSize / 2 {
                                    if hasMorePages {
                                        performSearch()
                                    }
                                }
                            }
                        }
                    }
                }
                .fancyTabScrollCompatible()
                .hoistNavigation(
                    dismiss: dismiss,
                    auxiliaryAction: {
                        withAnimation {
                            proxy.scrollTo(scrollToTop, anchor: .bottom)
                        }
                        return true
                    }
                )
            }
        }
    }
    
    private func getSearchTextBinding() -> Binding<String> {
        Binding(get: { searchText }, set: {
            searchText = $0
            
            // Revert to show suggestions if we clear the search
            showRecentSearches = searchText.isEmpty || lastSearchedText != searchText
        })
    }
    
    func performSearch() {
        // If we are searching, cancel the task
        if let task = searchTask {
            if !task.isCancelled {
                task.cancel()
                searchTask = nil
            }
        }
        
        // Fresh search, reset paging and results
        if lastSearchedText != searchText {
            searchPage = 1
            communitySearchResultsTracker.foundCommunities = []
        }
        
        // Only cache recent searches on first search
        if searchPage == 1 {
            recentSearchesTracker.addRecentSearch(searchText)
        }
        
        isSearching = true
        showRecentSearches = false
        lastSearchedText = searchText
        
        let currentSearchPage = searchPage
        searchPage += 1
        
        searchTask = Task(priority: .userInitiated) { [searchText] in
            do {
                defer {
                    isSearching = false
                }
                
                print("Searching for '\(searchText)' on page \(searchPage)")
                
                let response = try await apiClient.performSearch(
                    query: searchText,
                    searchType: .communities,
                    sortOption: .topAll,
                    listingType: .all,
                    page: currentSearchPage,
                    limit: searchPageSize
                )
                
                communitySearchResultsTracker.foundCommunities.append(contentsOf: response.communities)
                
                // We have more data to load if we get the amount we asked for
                hasMorePages = response.communities.count == searchPageSize
                
                print("Found \(response.communities.count) communities")
                
            } catch is CancellationError {
                print("Search cancelled")
            } catch {
                errorHandler.handle(error)
            }
        }
    }
}
