//
//  Search View.swift
//  Mlem
//
//  Created by Jake Shirley on 7/5/23.
//

import Foundation
import SwiftUI

struct SearchView: View {
    
    // environment
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var communitySearchResultsTracker: CommunitySearchResultsTracker
    @EnvironmentObject var recentSearchesTracker: RecentSearchesTracker

    // private state
    @State private var isSearching: Bool = false
    @State private var lastSearchedText: String = ""
    @State private var showRecentSearches: Bool = true
    @State private var searchTask: Task<(), Never>?
    @State private var searchText: String = ""
    
    @State private var searchPage: Int = 1
    @State private var hasMorePages: Bool = true
    
    @State private var navigationPath = NavigationPath()
    
    // constants
    private let searchPageSize = 50

    var body: some View {
        NavigationStack(path: $navigationPath) {
            content
                .handleLemmyViews()
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle("Search")
        }
        .handleLemmyLinkResolution(navigationPath: $navigationPath)
        .searchable(text: getSearchTextBinding(), prompt: "Search for communities")
        .onSubmit(of: .search) {
            performSearch()
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
        List {
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
        }.listStyle(.insetGrouped)
    }
    
    @ViewBuilder
    private var searchedContents: some View {
        if isSearching && communitySearchResultsTracker.foundCommunities.isEmpty {
            LoadingView(whatIsLoading: .search)
        } else if communitySearchResultsTracker.foundCommunities.isEmpty {
            Text("No communities found for search")
        } else {
            List {
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
        }
    }
    
    private func getSearchTextBinding() -> Binding<String> {
        return Binding(get: { searchText }, set: {
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
                
                let request = SearchRequest(
                    account: appState.currentActiveAccount,
                    query: searchText,
                    searchType: .communities,
                    sortOption: .topAll,
                    listingType: .all,
                    page: currentSearchPage,
                    limit: searchPageSize
                )
                
                let response = try await APIClient().perform(request: request)
                communitySearchResultsTracker.foundCommunities.append(contentsOf: response.communities)
                
                // We have more data to load if we get the amount we asked for
                hasMorePages = response.communities.count == searchPageSize
                
                print("Found \(response.communities.count) communities")
                
            } catch is CancellationError {
                print("Search cancelled")
            } catch {
                appState.contextualError = .init(underlyingError: error)
            }
        }
    }
}
