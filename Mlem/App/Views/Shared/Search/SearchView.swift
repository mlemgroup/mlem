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
    
    // Everything is treated as `home` right now, this `page` logic will be used later
    @State var page: Page = .home

    @State var selectedTab: Tab = .communities
    @State var resultsScrollToTopTrigger: Bool = false
    
    @State var communities: [Community2] = []
    @State var people: [Person2] = []
    @State var instances: [InstanceSummary] = []
    
    var body: some View {
        content
            .background(palette.background)
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.large)
            .navigationSearchBar {
                SearchBar("Communities, Users & Instances", text: $query, isEditing: $isSearching)
                    .showsCancelButton(page != .home)
                    .onCancel {
                        page = .home
                        if !query.isEmpty {
                            query = ""
                            Task { await refresh() }
                        }
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
                await refresh()
            }
            .onChange(of: appState.firstApi.actorId) {
                Task {
                    await refresh()
                }
            }
            .onChange(of: selectedTab) {
                Task {
                    do {
                        switch selectedTab {
                        case .communities:
                            if communities.isEmpty {
                                try await setCommunities(appState.firstApi.searchCommunities(query: query, page: 1, limit: 20))
                            }
                        case .users:
                            if people.isEmpty {
                                try await setPeople(appState.firstApi.searchPeople(query: query, page: 1, limit: 20))
                            }
                        case .instances:
                            if instances.isEmpty {
                                try await setInstances(MlemStats.main.searchInstances(query: query))
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
                label: { $0.label }
            )
            .padding(.top, -8)
            LazyVStack(spacing: 0) {
                switch selectedTab {
                case .communities:
                    SearchResultsView(results: communities) { community in
                        CommunityListRow(community, readout: .subscribers)
                    }
                case .users:
                    SearchResultsView(results: people) { person in
                        PersonListRow(person, complications: [.instance, .date], readout: .postsAndComments)
                    }
                case .instances:
                    SearchResultsView(results: instances) { instance in
                        InstanceListRow(instance, readout: .users)
                    }
                }
            }
        }
    }
    
    func refresh() async {
        do {
            if !query.isEmpty {
                try await Task.sleep(for: .seconds(0.2))
            }
            await setCommunities(.init())
            await setPeople(.init())
            await setInstances(.init())
            switch selectedTab {
            case .communities:
                try await setCommunities(appState.firstApi.searchCommunities(query: query, page: 1, limit: 20))
            case .users:
                try await setPeople(appState.firstApi.searchPeople(query: query, page: 1, limit: 20))
            case .instances:
                try await setInstances(MlemStats.main.searchInstances(query: query))
            }
        } catch {
            handleError(error)
        }
    }
    
    @MainActor
    func setCommunities(_ newValue: [Community2]) {
        communities = newValue
    }
    
    @MainActor
    func setPeople(_ newValue: [Person2]) {
        people = newValue
    }
    
    @MainActor
    func setInstances(_ newValue: [InstanceSummary]) {
        instances = newValue
    }
}
