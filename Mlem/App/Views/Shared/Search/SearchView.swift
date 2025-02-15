//
//  SearchView.swift
//  Mlem
//
//  Created by Sjmarf on 06/07/2024.
//

import MlemMiddleware
import SwiftUI

struct SearchView: View {
    enum Page {
        case home, recents, results
    }
    
    enum Tab: CaseIterable, Identifiable {
        case communities, people, instances, posts, comments
        
        var id: Self { self }
        
        var label: LocalizedStringResource {
            switch self {
            case .communities: "Communities"
            case .people: "Users"
            case .instances: "Instances"
            case .posts: "Posts"
            case .comments: "Comments"
            }
        }
    }
    
    @Environment(AppState.self) var appState
    @Environment(NavigationLayer.self) var navigation
    @Environment(Palette.self) var palette
    @Environment(FiltersTracker.self) var filtersTracker
    
    @Setting(\.compactComments) var compactComments
    
    @State var searchBarFocused: Bool = false
    @State var isSearching: Bool = false
    @State var query: String = ""
    @State var hasAppeared: Bool = false
    @State var page: Page = .home
    
    @State var filtersActive: Bool = false
    @State var communityFilters: CommunityFilters = .init()
    @State var personFilters: PersonFilters = .init()
    @State var instanceFilters: InstanceFilters = .init()
    @State var postFilters: PostFilters = .init()
    @State var commentFilters: CommentFilters = .init()
    
    @State var selectedTab: Tab = .communities
    @State var resultsScrollToTopTrigger: Bool = false
    
    @State var communityLoader: CommunityFeedLoader
    @State var personLoader: PersonFeedLoader
    @State var instances: [InstanceSummary] = []
    @State var postLoader: SearchPostFeedLoader
    @State var commentLoader: SearchCommentFeedLoader
    
    init(appState: AppState = .main) {
        self._communityLoader = .init(wrappedValue: .init(api: appState.firstApi))
        self._personLoader = .init(wrappedValue: .init(api: appState.firstApi))
        self._postLoader = .init(
            wrappedValue: .init(
                api: appState.firstApi,
                prefetchingConfiguration: .forPostSize(Settings.main.postSize),
                urlCache: Constants.main.urlCache
            )
        )
        self._commentLoader = .init(wrappedValue: .init(api: appState.firstApi))
    }
    
    @State var editingRecentSearches: Bool = false
    
    var body: some View {
        content
            .background(palette.groupedBackground)
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.large)
            .navigationSearchBar(searchBar)
            .navigationSearchBarHiddenWhenScrolling(false)
            .toolbar { PasteLinkButtonView() }
            .scrollDismissesKeyboard(.interactively)
            .onChange(of: query) {
                if page != .home {
                    if query.isEmpty {
                        page = .recents
                    } else {
                        page = .results
                    }
                }
            }
            .onChange(of: isSearching) {
                if isSearching, query.isEmpty {
                    page = .recents
                }
            }
//            // Don't use `.task` here, because it triggers when navigating back
            .onChange(of: query, initial: true, onQueryChange)
            .onChange(of: selectedTab, onTabChange)
            .onChange(of: filterRefreshHashValue, onFilterRefreshHashValueChange)
            .onChange(of: postFilters.location.instanceStub) {
                resolvePostFilterCreator()
            }
            .onDisappear {
                editingRecentSearches = false
            }
            .environment(\.feedContext, .search)
    }
    
    @ViewBuilder
    var content: some View {
        FancyScrollView(scrollToTopTrigger: $resultsScrollToTopTrigger) { searchBarFocused = true } content: {
            VStack(alignment: .leading, spacing: 0) {
                tabView
                if filtersActive, page != .home {
                    filtersView
                }
            }
            .padding(.top, -8)
            if page == .recents {
                recentSearchesListView
            } else {
                resultsListView
            }
        }
        .animation(.easeOut(duration: 0.1), value: filtersActive)
        .animation(.easeOut(duration: 0.2), value: page)
    }
    
    func searchBar() -> SearchBar {
        SearchBar(
            "Search...",
            text: $query,
            isEditing: $isSearching,
            onCommit: {
                if selectedTab == .posts || selectedTab == .comments {
                    Task { @MainActor in
                        await refresh(clearBeforeRefresh: true)
                    }
                }
            }
        )
        .returnKeyType(.search)
        .showsCancelButton(page != .home)
        .onCancel(perform: returnToHome)
        .focused($searchBarFocused)
    }
}

#Preview(traits: .sampleEnvironment(api: MockApiClient(
    communities: CommunityMockType.Realistic.allCases.map { Community2.mock(.realistic($0)) }))) {
        @Previewable @Environment(AppState.self) var appState
        NavigationStack {
            SearchView(appState: appState)
        }
    }
