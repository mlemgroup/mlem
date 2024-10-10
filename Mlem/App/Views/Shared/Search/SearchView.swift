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
        case communities, users, instances, posts
        
        var id: Self { self }
        
        var label: LocalizedStringResource {
            switch self {
            case .communities: "Communities"
            case .users: "Users"
            case .instances: "Instances"
            case .posts: "Posts"
            }
        }
    }
    
    @Environment(AppState.self) var appState
    @Environment(NavigationLayer.self) var navigation
    @Environment(Palette.self) var palette
    
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
        filteredKeywords: [],
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
                    communityLoader.api = appState.firstApi
                    personLoader.api = appState.firstApi
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
            switch selectedTab {
            case .communities:
                LazyVStack(spacing: 0) {
                    SearchResultsView(results: communityLoader.items) { community in
                        CommunityListRow(community, readout: .subscribers)
                            .onAppear {
                                do {
                                    try communityLoader.loadIfThreshold(community)
                                } catch {
                                    handleError(error)
                                }
                            }
                    }
                    EndOfFeedView(loadingState: communityLoader.loadingState, viewType: .hobbit)
                }
            case .users:
                LazyVStack(spacing: 0) {
                    SearchResultsView(results: personLoader.items) { person in
                        PersonListRow(person, complications: [.instance, .date], readout: .postsAndComments)
                            .onAppear {
                                do {
                                    try personLoader.loadIfThreshold(person)
                                } catch {
                                    handleError(error)
                                }
                            }
                    }
                    EndOfFeedView(loadingState: personLoader.loadingState, viewType: .hobbit)
                }
            case .instances:
                LazyVStack(spacing: 0) {
                    SearchResultsView(results: instances) { instance in
                        InstanceListRow(instance, readout: .users)
                    }
                    EndOfFeedView(loadingState: .done, viewType: .hobbit)
                }
            case .posts:
                if postLoader.loadingState == .idle, postLoader.items.isEmpty {
                    searchPlaceholder
                        .padding(.top, 30)
                } else {
                    PostGridView(postFeedLoader: postLoader)
                }
            }
        }
        .animation(.easeOut(duration: 0.1), value: filtersActive)
    }
    
    @ViewBuilder
    var tabView: some View {
        HStack {
            BubblePicker(
                Tab.allCases, selected: $selectedTab,
                label: { $0.label }
            )
            .overlay(alignment: .trailing) {
                LinearGradient(
                    colors: [Color.clear, palette.groupedBackground],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: 10)
            }
            if page != .home {
                Button {
                    HapticManager.main.play(haptic: .gentleInfo, priority: .low)
                    filtersActive.toggle()
                } label: {
                    Label("Filters", systemImage: filtersActive ? Icons.filterFill : Icons.filter)
                        .transaction { $0.animation = nil }
                }
                .labelStyle(.iconOnly)
                .padding(.trailing)
                .imageScale(.large)
            }
        }
        .animation(.easeOut(duration: 0.1), value: page)
    }
    
    @ViewBuilder
    var searchPlaceholder: some View {
        VStack(spacing: 20) {
            Image(systemName: Icons.search)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120)
                .fontWeight(.thin)
                .foregroundStyle(palette.tertiary)
            Text("Search for posts across Lemmy")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(palette.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
    }
}
