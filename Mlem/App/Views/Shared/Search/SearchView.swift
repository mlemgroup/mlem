//
//  SearchView.swift
//  Mlem
//
//  Created by Sjmarf on 06/07/2024.
//

import Haptics
import MlemMiddleware
import MlemBackend
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
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @Setting(\.comment_compact) var compactComments
    
    @State var isSearching: Bool = false
    @State var query: String = ""

    // Separate state var to avoid unnecessary view updates
    @State var queryIsEmpty: Bool = true
    @State var hasAppeared: Bool = false
    
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
    
    @State var editingRecentSearches: Bool = false
    @State var lastExecutedQuery: [Tab: String] = .init()
    
    init(appState: AppState = .main) {
        self._communityLoader = .init(wrappedValue: .init(api: appState.firstApi))
        self._personLoader = .init(wrappedValue: .init(api: appState.firstApi))
        self._postLoader = .init(
            wrappedValue: .init(
                api: appState.firstApi,
                sortType: .top(.allTime),
                prefetchingConfiguration: .forPostSize(Settings.get(\.post_size)),
                urlCache: Constants.main.urlCache
            )
        )
        self._commentLoader = .init(wrappedValue: .init(api: appState.firstApi))
    }
    
    var body: some View {
        content
            .background(ThemedColor.themedGroupedBackground)
            .themedGroupedBackground()
            .navigationTitle(horizontalSizeClass == .regular ? "" : "Search")
            .navigationBarTitleDisplayMode(horizontalSizeClass == .regular ? .inline : .large)
            .searchable(
                text: $query,
                isPresented: $isSearching,
                placement: .toolbarPrincipal,
                prompt: "Search..."
            )
            .autocorrectionDisabled(!selectedTab.shouldAutocorrect)
            .onSubmit(of: .search) {
                if selectedTab == .posts || selectedTab == .comments {
                    Task { @MainActor in
                        await refresh(clearBeforeRefresh: true)
                    }
                }
            }
            .toolbar {
                toolbarContent
            }
            .scrollDismissesKeyboard(.interactively)
            .onChange(of: query) { _, newValue in
                if self.queryIsEmpty != newValue.isEmpty {
                    self.queryIsEmpty = newValue.isEmpty
                }
                if newValue.hasPrefix("@") || newValue.hasPrefix("!") {
                    selectedTab = newValue.hasPrefix("@") ? .people : .communities
                    query = ""
                    isSearching = true
                    contentChangeTriggerDebouncedRefresh()
                }
                lastExecutedQuery[selectedTab] = query
            }
            // Don't use `.task` here, because it triggers when navigating back
            .onChange(of: query, initial: true) { oldValue, newValue in
                if oldValue != newValue || selectedTab == .communities && communityLoader.items.isEmpty && !isSearching {
                    contentChangeTriggerDebouncedRefresh()
                }
            }
            .onChange(of: selectedTab) {
                contentChangeTriggerRefresh()
            }
            .onChange(of: filterRefreshHashValue, onFilterRefreshHashValueChange)
            .onChange(of: postFilters?.location.instanceStub) {
                resolvePostFilterCreator()
            }
            .onDisappear {
                editingRecentSearches = false
            }
            .environment(\.feedContext, .search)
            .onChange(of: appState.firstApi) {
                communityFilters = nil
                personFilters = nil
                postFilters = nil
            }
            .task(id: appState.firstApi) { await setupFilters() }
    }

    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        if horizontalSizeClass == .regular {
            ToolbarItem(placement: .topBarLeading) {
                Menu {
                    Picker(selectedTab.label, selection: $selectedTab) {
                        ForEach(Tab.allCases, id: \.self) { tab in
                            Text(tab.label)
                        }
                    }
                } label: {
                    HStack {
                        Text(selectedTab.label)
                        Image(icon: .general.dropDown)
                            .imageScale(.small)
                    }
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Toggle("Filters", icon: .general.filterMenu, isOn: $filtersActive)
            }
        }
        ToolbarItem(placement: .topBarTrailing) {
            PasteLinkButtonView()
        }
    }
    
    @ViewBuilder
    var content: some View {
        FancyScrollView(scrollToTopTrigger: $resultsScrollToTopTrigger) { isSearching = true } content: {
            VStack(alignment: .leading, spacing: 0) {
                if page != .home, horizontalSizeClass == .compact {
                    tabView
                }
                if filtersActive, page != .home || horizontalSizeClass == .regular {
                    filtersView
                }
            }
            switch page {
            case .recents:
                recentSearchesListView
            case .home:
                SearchHomeView()
                    .frame(maxWidth: .infinity)
                    .geometryGroup()
            case .results:
                resultsListView
                    .frame(maxWidth: .infinity)
                    .geometryGroup()
            }
        }
        .animation(.easeOut(duration: 0.1), value: filtersActive)
        .animation(.easeOut(duration: 0.2), value: page)
        .contentMargins(.top, horizontalSizeClass == .compact ? -8 : 0)
    }
}

// TODO: updated mocks
// #if DEBUG
//    #Preview(traits: .sampleEnvironment(api: .realistic)) {
//        @Previewable @Environment(AppState.self) var appState
//        NavigationStack {
//            SearchView(appState: appState)
//        }
//    }
// #endif
