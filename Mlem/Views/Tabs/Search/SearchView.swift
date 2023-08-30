//
//  Search View.swift
//  Mlem
//
//  Created by Jake Shirley on 7/5/23.
//

import Dependencies
import Foundation
import SwiftUI

struct SearchView: View {
    
    @Dependency(\.errorHandler) var errorHandler
    
    @StateObject var searchModel = SearchModel()
    @StateObject var postTracker: PostTracker
    
    @State private var navigationPath = NavigationPath()

    init() {
        @AppStorage("internetSpeed") var internetSpeed: InternetSpeed = .fast
        self._postTracker = StateObject(wrappedValue: .init(internetSpeed: internetSpeed))
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            content
                .background(Color(UIColor.systemGroupedBackground))
                .handleLemmyViews()
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarColor()
                .navigationTitle("Search")
                .searchable(text: $searchModel.input)
                .autocorrectionDisabled(true)
                .textInputAutocapitalization(.never)
        }
        .environmentObject(postTracker)
        .environment(\.navigationPath, $navigationPath)
        .handleLemmyLinkResolution(navigationPath: $navigationPath)
        .onChange(of: searchModel.input) { newValue in
            searchModel.taskID = newValue.hashValue
        }
        .task(id: searchModel.taskID, priority: .userInitiated) {
            do {
                try await searchModel.fetchResults()
            } catch {
                errorHandler.handle(error)
            }
        }
    }
    
    var content: some View {
        ScrollView {
            
            // This is necessary for the Communities section header material
            Spacer()
                .frame(height: 1)
            
            VStack(spacing: 3) {
                if !searchModel.suggestedFilters.isEmpty || !searchModel.activeFilters.isEmpty {
                    if !searchModel.activeFilters.isEmpty {
                        HStack {
                            SearchFilterListView(
                                filters: searchModel.activeFilters,
                                active: true,
                                shouldAnimate: !searchModel.suggestedFilters.isEmpty || searchModel.activeFilters.count > 1
                            )
                            Button("Clear") {
                                withAnimation {
                                    searchModel.clearFilters()
                                }
                            }
                            .foregroundStyle(.blue)
                            .padding(.trailing, 20)
                            .buttonStyle(.plain)
                        }
                    }
                    if !searchModel.suggestedFilters.isEmpty {
                        SearchFilterListView(
                            filters: searchModel.suggestedFilters,
                            active: false,
                            shouldAnimate: !searchModel.activeFilters.isEmpty
                        )
                    }
                    Divider()
                        .padding(.vertical, 6)
                }
            }
            LazyVStack(pinnedViews: [.sectionHeaders]) {
                
                ForEach(searchModel.sections, id: \.self) { section in
                    switch section {
                    case .communities:
                        if !searchModel.communities.isEmpty {
                            communityResults
                        }
                    case .users:
                        if !searchModel.users.isEmpty {
                            userResults
                        }
                    case .posts:
                        if !searchModel.posts.isEmpty {
                            postResults
                        }
                    case .comments:
                        Spacer().frame(height: 1)
                    }
                }
            }
            Spacer()
                .frame(height: 40)
        }
        .coordinateSpace(name: "searchArea")
        .fancyTabScrollCompatible()
        .environmentObject(searchModel)
    }
    
    var communityResults: some View {
        Section {
            ForEach(searchModel.communities, id: \.self) { community in
                CommunityResultView(community: community)
            }
            .padding(.horizontal, 20)
        } header: {
            SearchSectionHeaderView(title: "Communities")
        }
    }
    
    var userResults: some View {
        Section {
            ForEach(searchModel.users, id: \.self) { user in
                UserResultView(user: user)
            }
            .padding(.horizontal, 20)
        } header: {
            SearchSectionHeaderView(title: "Users")
        }
    }
    
    var postResults: some View {
        Section {
            VStack(spacing: 0) {
                ForEach(searchModel.posts, id: \.self) { post in
                    Group {
                        NavigationLink(value: PostLinkWithContext(post: post, postTracker: postTracker)) {
                            UltraCompactPost(postView: post, showCommunity: searchModel.activeCommunityFilter == nil)
                                .padding(.horizontal, 10)
                        }
                        Divider()
                    }
                }
            }
        } header: {
            SearchSectionHeaderView(title: "Posts")
        }
    }
}
