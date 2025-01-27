//
//  SearchView+Views.swift
//  Mlem
//
//  Created by Sjmarf on 2025-01-01.
//

import SwiftUI

extension SearchView {
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
    var resultsListView: some View {
        switch selectedTab {
        case .communities:
            LazyVStack(spacing: 0) {
                SearchResultsView(results: communityLoader.items) { community in
                    CommunityListRow(
                        community,
                        readout: .subscribers,
                        visitContext: page == .home ? .other : .search
                    )
                    .onAppear {
                        do {
                            try communityLoader.loadIfThreshold(community)
                        } catch {
                            handleError(error)
                        }
                    }
                }
                EndOfFeedView(loadingState: communityLoader.loadingState, loadMore: nil, viewType: .hobbit)
            }
        case .people:
            LazyVStack(spacing: 0) {
                SearchResultsView(results: personLoader.items) { person in
                    PersonListRow(
                        person,
                        complications: [.instance, .date],
                        readout: .postsAndComments,
                        visitContext: page == .home ? .other : .search
                    )
                    .onAppear {
                        do {
                            try personLoader.loadIfThreshold(person)
                        } catch {
                            handleError(error)
                        }
                    }
                }
                EndOfFeedView(loadingState: personLoader.loadingState, loadMore: nil, viewType: .hobbit)
            }
        case .instances:
            LazyVStack(spacing: 0) {
                SearchResultsView(results: instances) { instance in
                    InstanceListRow(
                        instance,
                        readout: .users,
                        visitContext: page == .home ? .other : .search
                    )
                }
                EndOfFeedView(loadingState: .done, loadMore: nil, viewType: .hobbit)
            }
        case .posts:
            if postLoader.loadingState == .idle, postLoader.items.isEmpty {
                searchPlaceholder
            } else {
                PostGridView(postFeedLoader: postLoader)
            }
        case .comments:
            if commentLoader.loadingState == .idle, commentLoader.items.isEmpty {
                searchPlaceholder
            } else {
                LazyVStack(spacing: compactComments ? Constants.main.halfSpacing : Constants.main.standardSpacing) {
                    ForEach(commentLoader.items, id: \.actorId) { comment in
                        NavigationLink(.comment(comment)) {
                            FeedCommentView(comment: comment)
                        }
                        .buttonStyle(.empty)
                        .onAppear {
                            do {
                                try commentLoader.loadIfThreshold(comment)
                            } catch {
                                handleError(error)
                            }
                        }
                    }
                    EndOfFeedView(loadingState: commentLoader.loadingState, loadMore: nil, viewType: .hobbit)
                }
                .padding(.horizontal, Constants.main.standardSpacing)
            }
        }
    }
    
    @ViewBuilder
    var recentSearchesListView: some View {
        if let session = appState.firstSession as? UserSession,
           let visitHistory = session.visitHistory {
            switch selectedTab {
            case .communities:
                let items = visitHistory.communities(withContext: .search)
                if !items.isEmpty {
                    recentSearchesHeader
                    SearchResultsView(results: items) { community in
                        HStack {
                            CommunityListRow(community, readout: .subscribers)
                            deleteRecentSearchButton(session: session) {
                                visitHistory.removeCommunity(community, context: .search)
                            }
                        }
                    }
                } else {
                    searchPlaceholder
                }
            case .people:
                let items = visitHistory.people(withContext: .search)
                if !items.isEmpty {
                    recentSearchesHeader
                    SearchResultsView(results: items) { person in
                        HStack {
                            PersonListRow(person, readout: .postsAndComments)
                            deleteRecentSearchButton(session: session) {
                                visitHistory.removePerson(person, context: .search)
                            }
                        }
                    }
                } else {
                    searchPlaceholder
                }
            case .instances:
                let items = visitHistory.instances(withContext: .search)
                if !items.isEmpty {
                    recentSearchesHeader
                    SearchResultsView(results: items) { instance in
                        HStack {
                            InstanceListRow(instance, readout: .users)
                            deleteRecentSearchButton(session: session) {
                                visitHistory.removeInstance(instance, context: .search)
                            }
                        }
                    }
                } else {
                    searchPlaceholder
                }
            default:
                searchPlaceholder
            }
        } else {
            searchPlaceholder
        }
    }
    
    @ViewBuilder
    var recentSearchesHeader: some View {
        HStack {
            if editingRecentSearches {
                Button("Done") {
                    withAnimation {
                        editingRecentSearches = false
                    }
                }
            } else {
                Text("Recently Searched")
                    .foregroundStyle(palette.primary)
            }
            
            Spacer()
            
            if editingRecentSearches {
                ClearRecentSearchesButton()
            } else {
                Button("Edit") {
                    withAnimation {
                        editingRecentSearches = true
                    }
                }
            }
        }
        .font(.callout)
        .bold()
        .padding(.horizontal, 15)
        .padding(.bottom, Constants.main.standardSpacing)
        .padding(.top, Constants.main.standardSpacing)
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
            Text(searchPlaceholderTitle)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(palette.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
        .padding(.top, 30)
    }

    var searchPlaceholderTitle: LocalizedStringResource {
        switch selectedTab {
        case .communities: "Search for communities"
        case .instances: "Search for Lemmy instances"
        case .people: "Search for users"
        case .posts: "Search for posts"
        case .comments: "Search for comments"
        }
    }

    struct ClearRecentSearchesButton: View {
        @Environment(AppState.self) var appState
        
        @State var showingConfirmation: Bool = false
        
        var body: some View {
            Button("Clear") {
                showingConfirmation = true
            }
            .confirmationDialog(
                "Clear search history?",
                isPresented: $showingConfirmation,
                titleVisibility: .visible
            ) {
                Button("Clear", role: .destructive) {
                    if let session = appState.firstSession as? UserSession, let visitHistory = session.visitHistory {
                        visitHistory.clear()
                        Task {
                            do {
                                try await session.saveVisitHistory()
                            } catch {
                                handleError(error)
                            }
                        }
                    }
                }
                Button("Turn Off Search History", role: .destructive) {
                    if let session = appState.firstSession as? UserSession {
                        Task { @MainActor in
                            do {
                                try await session.setVisitHistoryEnabled(false)
                            } catch {
                                handleError(error)
                            }
                        }
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("You can also turn off search history completely for this account.")
            }
        }
    }
    
    @ViewBuilder
    func deleteRecentSearchButton(session: UserSession, callback: @escaping (() -> Void)) -> some View {
        if editingRecentSearches {
            Button("Remove Recent Search", systemImage: Icons.delete) {
                withAnimation {
                    callback()
                }
                Task(priority: .background) {
                    try await session.saveVisitHistory()
                }
            }
            .labelStyle(.iconOnly)
            .foregroundStyle(palette.negative)
            .padding(.horizontal, Constants.main.halfSpacing)
        }
    }
}
