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
        case communities, users, instances
        
        var id: Self { self }
        
        var label: LocalizedStringResource {
            switch self {
            case .communities: "Communities"
            case .users: "Users"
            case .instances: "Instances"
            }
        }
    }
    
    @Environment(Palette.self) var palette
    @Environment(AppState.self) var appState
    
    @State var searchBarFocused: Bool = false
    @State var isSearching: Bool = false
    @State var query: String = ""
    @State var hasAppeared: Bool = false
    @State var page: Page = .home
    
    @State var filtersActive: Bool = false
    @Bindable var communityFilters: CommunityFilters = .init(sort: .topAll)

    @State var selectedTab: Tab = .communities
    @State var resultsScrollToTopTrigger: Bool = false
    
    @State var communityLoader: CommunityFeedLoader = .init(api: AppState.main.firstApi)
    @State var personLoader: PersonFeedLoader = .init(api: AppState.main.firstApi)
    @State var instances: [InstanceSummary] = []
    
    var body: some View {
        content
            .background(palette.background)
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.large)
            .navigationSearchBar {
                SearchBar("Communities, Users & Instances", text: $query, isEditing: $isSearching)
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
            .task(id: query, priority: .userInitiated) { @MainActor in
                guard !hasAppeared || searchBarFocused else { return }
                hasAppeared = true
                await refresh(clearBeforeRefresh: false)
            }
            .onChange(of: appState.firstApi.actorId) {
                Task {
                    communityLoader.api = appState.firstApi
                    personLoader.api = appState.firstApi
                    await refresh(clearBeforeRefresh: false)
                }
            }
            .onChange(of: selectedTab) {
                Task {
                    await refresh(clearBeforeRefresh: false, onlyRefreshIfEmpty: true)
                }
            }
            .onChange(of: filterRefreshHashValue) {
                Task {
                    await refresh(clearBeforeRefresh: true)
                }
            }
    }
    
    @ViewBuilder
    var content: some View {
        FancyScrollView(scrollToTopTrigger: $resultsScrollToTopTrigger) { searchBarFocused = true } content: {
            VStack(alignment: .leading, spacing: 0) {
                tabView
                Divider()
                if filtersActive, page != .home {
                    filtersView
                    Divider()
                }
            }
            .padding(.top, -8)
            LazyVStack(spacing: 0) {
                switch selectedTab {
                case .communities:
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
                case .users:
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
                case .instances:
                    SearchResultsView(results: instances) { instance in
                        InstanceListRow(instance, readout: .users)
                    }
                    EndOfFeedView(loadingState: .done, viewType: .hobbit)
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
                    colors: [Color.clear, palette.background],
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
}
