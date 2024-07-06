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
    
    enum Tab: String, CaseIterable, Identifiable {
        case communities, users, instances
        
        var id: String { rawValue }
    }
    
    @Environment(Palette.self) var palette
    @Environment(AppState.self) var appState
    
    @State var searchBarFocused: Bool = false
    @State var isSearching: Bool = false
    @State var query: String = ""
    @State var hasAppeared: Bool = false
    
    // Everything is treated as `home` right now, this `page` logic will be used later
    @State var page: Page = .home

    @State var selectedTab: Tab = .communities
    @State var resultsScrollToTopTrigger: Bool = false
    
    @State var communities: [Community2] = []
    @State var people: [Person2] = []
    @State var instances: [InstanceSummary] = []
    
    var body: some View {
        content
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.large)
            .navigationSearchBar {
                SearchBar("Communities, Users & Instances", text: $query, isEditing: $isSearching)
                    .showsCancelButton(page != .home)
                    .onCancel {
                        page = .home
                        query = ""
                        resultsScrollToTopTrigger.toggle()
                    }
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
                do {
                    if !query.isEmpty {
                        try await Task.sleep(for: .seconds(0.2))
                    }
                    communities.removeAll()
                    people.removeAll()
                    instances.removeAll()
                    switch selectedTab {
                    case .communities:
                        communities = try await appState.firstApi.searchCommunities(query: query, page: 1, limit: 20)
                    case .users:
                        people = try await appState.firstApi.searchPeople(query: query, page: 1, limit: 20)
                    case .instances:
                        instances = try await MlemStats.main.searchInstances(query: query)
                    }
                } catch {
                    handleError(error)
                }
            }
            .onChange(of: selectedTab) {
                Task { @MainActor in
                    do {
                        switch selectedTab {
                        case .communities:
                            if communities.isEmpty {
                                communities = try await appState.firstApi.searchCommunities(query: query, page: 1, limit: 20)
                            }
                        case .users:
                            if people.isEmpty {
                                people = try await appState.firstApi.searchPeople(query: query, page: 1, limit: 20)
                            }
                        case .instances:
                            if instances.isEmpty {
                                instances = try await MlemStats.main.searchInstances(query: query)
                            }
                        }
                    } catch {
                        handleError(error)
                    }
                }
            }
    }
    
    @ViewBuilder
    var content: some View {
        FancyScrollView(scrollToTopTrigger: $resultsScrollToTopTrigger) { searchBarFocused = true } content: {
            BubblePicker(
                Tab.allCases, selected: $selectedTab,
                withDividers: [.bottom],
                label: { $0.rawValue.capitalized }
            )
            .padding(.top, -10)
            LazyVStack(spacing: 0) {
                switch selectedTab {
                case .communities:
                    SearchResultsView(results: communities) { community in
                        CommunityListRow(community, readout: .subscribers)
                            .padding(.vertical, 6)
                    }
                case .users:
                    SearchResultsView(results: people) { person in
                        PersonListRowBody(person, readout: .postsAndComments)
                            .padding(.vertical, 6)
                    }
                case .instances:
                    SearchResultsView(results: instances) { instance in
                        InstanceListRowBody(instance)
                            .padding(.vertical, 6)
                    }
                }
            }
        }
    }
}
