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
        case communities, people, instances, posts
        
        var id: Self { self }
        
        var label: LocalizedStringResource {
            switch self {
            case .communities: "Communities"
            case .people: "Users"
            case .instances: "Instances"
            case .posts: "Posts"
            }
        }
    }
    
    @Environment(AppState.self) var appState
    @Environment(NavigationLayer.self) var navigation
    @Environment(Palette.self) var palette
    @Environment(FiltersTracker.self) var filtersTracker
    
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
    
    @State var selectedTab: Tab = .communities
    @State var resultsScrollToTopTrigger: Bool = false
    
    @State var communityLoader: CommunityFeedLoader = .init(api: AppState.main.firstApi)
    @State var personLoader: PersonFeedLoader = .init(api: AppState.main.firstApi)
    @State var instances: [InstanceSummary] = []
    @State var postLoader: SearchPostFeedLoader = .init(
        api: AppState.main.firstApi,
        prefetchingConfiguration: .forPostSize(Settings.main.postSize),
        urlCache: Constants.main.urlCache
    )
    
    var body: some View {
        content
            .background(palette.groupedBackground)
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.large)
            .navigationSearchBar {
                SearchBar(
                    "Search...",
                    text: $query,
                    isEditing: $isSearching,
                    onCommit: {
                        if selectedTab == .posts {
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
            // Don't use `.task` here, because it triggers when navigating back
            .onChange(of: query, initial: true) { oldValue, newValue in
                Task { @MainActor in
                    if selectedTab == .posts {
                        if oldValue != newValue {
                            await postLoader.clear()
                        }
                        return
                    }
                    guard !hasAppeared || searchBarFocused else { return }
                    hasAppeared = true
                    await refresh(clearBeforeRefresh: false)
                }
            }
            .onChange(of: appState.firstApi.actorId) {
                Task {
                    await refresh(clearBeforeRefresh: false)
                }
            }
            .onChange(of: selectedTab) {
                if selectedTab == .posts {
                    if page != .results {
                        searchBarFocused = true
                    }
                } else {
                    Task {
                        await refresh(clearBeforeRefresh: false, onlyRefreshIfEmpty: true)
                    }
                }
            }
            .onChange(of: filterRefreshHashValue) {
                Task {
                    await refresh(clearBeforeRefresh: selectedTab == .posts)
                }
            }
            .onChange(of: postFilters.location.instanceStub) {
                resolvePostFilterCreator()
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
}
