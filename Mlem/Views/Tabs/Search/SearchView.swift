//
//  Search View.swift
//  Mlem
//
//  Created by Jake Shirley on 7/5/23.
//

import Dependencies
import Foundation
import SwiftUI

private struct ViewOffsetKey: PreferenceKey {
    public typealias Value = CGFloat
    public static var defaultValue = CGFloat.zero
    public static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}

struct SearchView: View {
    
    @Dependency(\.errorHandler) var errorHandler
    
    @StateObject var searchModel = SearchModel()
    @StateObject var postTracker: PostTracker
    
    @State private var navigationPath = NavigationPath()
    @State var atTopOfScrollView: Bool = false
    
    @State var wholeSize: CGSize = .zero
    @State var scrollViewSize: CGSize = .zero
    
    @FocusState private var focused: Bool
    
    let horizontalPadding: CGFloat = 15

    init() {
        @AppStorage("internetSpeed") var internetSpeed: InternetSpeed = .fast
        self._postTracker = StateObject(wrappedValue: .init(internetSpeed: internetSpeed))
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            content
                .background(Color(UIColor.systemGroupedBackground))
                .handleLemmyViews()
                // .navigationBarColor()

        }
        .environmentObject(postTracker)
        .environment(\.navigationPath, $navigationPath)
        .handleLemmyLinkResolution(navigationPath: $navigationPath)

    }
    
    var searchBar: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                HStack(spacing: 5) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                        .imageScale(.medium)
                    TextField("Search", text: $searchModel.input)
                        .focused($focused)
                        .textFieldStyle(.plain)
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.never)
                        .onChange(of: focused) { searchModel.focused = $0 }
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
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(atTopOfScrollView ? Color(.systemGray5) : Color(.systemGray3))
                        .opacity(0.7)
                )
                if focused || !searchModel.input.isEmpty || !searchModel.activeFilters.isEmpty {
                    Button("Cancel") {
                        withAnimation {
                            focused = false
                            searchModel.input = ""
                            searchModel.clearFilters()
                        }
                    }
                    .foregroundStyle(.blue)
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, horizontalPadding)
            .padding(.top, 12)
            .padding(.bottom, 6)
            if !searchModel.suggestedFilters.isEmpty || !searchModel.activeFilters.isEmpty {
                if !searchModel.activeFilters.isEmpty {
                    SearchFilterListView(
                        filters: searchModel.activeFilters,
                        active: true,
                        shouldAnimate: !searchModel.suggestedFilters.isEmpty || searchModel.activeFilters.count > 1
                    )
                    .padding(.vertical, 6)
                }
            }
        }
        .padding(.bottom, 6)
    }
    
    var content: some View {
        GeometryReader { outerGeometry in
            ScrollViewReader { scrollProxy in
                ScrollView {
                    Spacer()
                        .frame(height: 1)
                        .background(
                            GeometryReader {
                                Color.clear.preference(key: ViewOffsetKey.self, value: $0.frame(in: .named("searchArea")).origin.y)
                                
                            }
                        )
                        .onPreferenceChange(ViewOffsetKey.self) {
                            self.atTopOfScrollView = Int($0) >= 0
                        }
                    
                    if !searchModel.suggestedFilters.isEmpty {
                        SearchFilterListView(
                            filters: searchModel.suggestedFilters,
                            active: false,
                            shouldAnimate: !searchModel.activeFilters.isEmpty
                        )
                        .padding(.bottom, 6)
                    }
                    LazyVStack(spacing: 10) { // pinnedViews: [.sectionHeaders]
                        
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
//                    if searchModel.activeTypeFilter != nil {
//                        ProgressView()
//                            .padding(.top, 15)
//                    }
                    Spacer()
                        .frame(height: 40)
//                        .background(
//                            GeometryReader {
//                                Color.clear.preference(key: ViewOffsetKey.self, value: $0.frame(in: .named("searchArea")).origin.y)
//                                
//                            }
//                        )
//                        .onPreferenceChange(ViewOffsetKey.self) {
//                            if $0 < outerGeometry.size.height + 200 {
//                                if searchModel.loadedPage >= 1 && searchModel.activeTypeFilter != nil && searchModel.page != searchModel.loadedPage + 1 {
//                                    searchModel.page = searchModel.loadedPage + 1
//                                }
//                            }
//                        }
//                        .task(id: searchModel.page, priority: .userInitiated) {
//                            print("TASK", searchModel.page, searchModel.loadedPage)
//                            do {
//                                try await searchModel.loadMore()
//                            } catch {
//                                errorHandler.handle(error)
//                            }
//                        }
                }
                .coordinateSpace(name: "searchArea")
                .fancyTabScrollCompatible()
                .safeAreaInset(edge: .top, spacing: 0) {
                    VStack {
                        searchBar
                            .background(.bar.opacity(atTopOfScrollView ? 0 : 1))
                        //                if !atTopOfScrollView {
                        //                    Divider()
                        //                }
                    }
                    .animation(.easeOut(duration: 0.1), value: atTopOfScrollView)
                }
                .environmentObject(searchModel)
            }
        }
    }
    
    var communityResults: some View {
        Section {
            ForEach(searchModel.communities, id: \.self) { community in
                CommunityResultView(community: community)
            }
            .padding(.horizontal, horizontalPadding)
        } header: {
            SearchSectionHeaderView(title: "Communities", filter: .communities)
        }
    }
    
    var userResults: some View {
        Section {
            ForEach(searchModel.users, id: \.self) { user in
                UserResultView(user: user)
            }
            .padding(.horizontal, horizontalPadding)
        } header: {
            SearchSectionHeaderView(title: "Users", filter: .users)
        }
    }
    
    var postResults: some View {
        Section {
            VStack(spacing: 10) {
                ForEach(searchModel.posts, id: \.self) { post in
                    Group {
                        NavigationLink(value: PostLinkWithContext(post: post, postTracker: postTracker)) {
                            PostResultView(postView: post, showCommunity: searchModel.activeCommunityFilter == nil, searchModel: searchModel)
                                .padding(.horizontal, horizontalPadding)
                        }
                    }
                }
            }
        } header: {
            SearchSectionHeaderView(title: "Posts", filter: .posts)
        }
    }
}
