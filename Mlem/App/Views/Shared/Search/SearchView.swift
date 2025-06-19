//
//  SearchView.swift
//  Mlem
//
//  Created by Sjmarf on 06/07/2024.
//

import Haptics
import MlemMiddleware
import SwiftUI
import Theming

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
        
        var shouldAutocorrect: Bool {
            switch self {
            case .comments, .posts: true
            case .communities, .people, .instances: false
            }
        }
    }
    
    @Environment(AppState.self) var appState
    @Environment(HapticManager.self) var hapticManager
    @Environment(NavigationLayer.self) var navigation
    @Environment(FiltersTracker.self) var filtersTracker
    @Environment(\.palette) var palette
    
    @Setting(\.comment_compact) var compactComments
    
    @State var searchBarFocused: Bool = false
    @State var isSearching: Bool = false
    @State var query: String = ""
    @State var hasAppeared: Bool = false
    @State var page: Page = .home
    
    @State var filtersActive: Bool = false
    @State var communityFilters: CommunityFilters?
    @State var personFilters: PersonFilters?
    @State var instanceFilters: InstanceFilters = .init()
    @State var postFilters: PostFilters?
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
                sortType: .v3(.top(.allTime)),
                prefetchingConfiguration: .forPostSize(Settings.get(\.post_size)),
                urlCache: Constants.main.urlCache
            )
        )
        self._commentLoader = .init(wrappedValue: .init(api: appState.firstApi))
    }
    
    @State var editingRecentSearches: Bool = false
    
    var body: some View {
        content
            .background(ThemedColor.themedGroupedBackground)
            .themedGroupedBackground()
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.large)
            .navigationSearchBar(searchBar)
            .autocorrectionDisabled(!selectedTab.shouldAutocorrect)
            .navigationSearchBarHiddenWhenScrolling(false)
            .toolbar { PasteLinkButtonView() }
            .scrollDismissesKeyboard(.interactively)
            .onChange(of: query) { _, newValue in
                switch newValue {
                case let str where str.hasPrefix("@"), let str where str.hasPrefix("!"):
                    selectedTab = str.hasPrefix("@") ? .people : .communities
                    query = ""
                    page = .recents
                    searchBarFocused = true
                    contentChangeTriggerRefresh(onlyRefreshIfEmpty: false)
                    
                default:
                    if page != .home {
                        page = query.isEmpty ? .recents : .results
                    }
                }
            }
            .onChange(of: isSearching) {
                if isSearching, query.isEmpty {
                    page = .recents
                }
            }
//            // Don't use `.task` here, because it triggers when navigating back
            .onChange(of: query, initial: true) { oldValue, newValue in
                if oldValue != newValue || selectedTab == .communities && communityLoader.items.isEmpty && !isSearching {
                    contentChangeTriggerRefresh(onlyRefreshIfEmpty: false)
                }
            }
            .onChange(of: selectedTab) { contentChangeTriggerRefresh(onlyRefreshIfEmpty: true) }
            .onChange(of: filterRefreshHashValue, onFilterRefreshHashValueChange)
            .onChange(of: postFilters?.location.instanceStub) {
                resolvePostFilterCreator()
            }
            .onDisappear {
                editingRecentSearches = false
            }
            .environment(\.feedContext, .search)
            .task(id: appState.firstApi) { await setupFilters() }
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

#if DEBUG
    #Preview(traits: .sampleEnvironment(api: .realistic)) {
        @Previewable @Environment(AppState.self) var appState
        NavigationStack {
            SearchView(appState: appState)
        }
    }
#endif
