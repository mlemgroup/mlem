//
//  FeedsView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-01-07.
//

import Dependencies
import Foundation
import MlemMiddleware
import SwiftUI

struct FeedsView: View {
    @Environment(AppState.self) var appState
    
    var body: some View {
        content
    }
    
    var content: some View {
        MinimalPostFeedView()
    }
}

enum DummyBubble: String, CaseIterable, Identifiable {
    var id: Self { self }
    
    case option, another, third
}

struct MinimalPostFeedView: View {
    @AppStorage("post.size") var postSize: PostSize = .large
    @AppStorage("feed.showRead") var showRead: Bool = true
    @AppStorage("beta.tilePosts") var tilePosts: Bool = false
    
    @Environment(AppState.self) var appState
    @Environment(Palette.self) var palette
    
    @State var postFeedLoader: StandardPostFeedLoader
    @State var isAtTop: Bool = true
    @State var columns: [GridItem] = [GridItem(.flexible())]
    @State var dummyBubble: DummyBubble = .option
    
    init() {
        // need to grab some stuff from app storage to initialize with
        @AppStorage("internetSpeed") var internetSpeed: InternetSpeed = .fast
        @AppStorage("upvoteOnSave") var upvoteOnSave = false
        @AppStorage("feed.showRead") var showReadPosts = true
        @AppStorage("defaultPostSorting") var defaultPostSorting: ApiSortType = .hot
        
        @Dependency(\.persistenceRepository) var persistenceRepository
        
        _postFeedLoader = .init(initialValue: .init(
            pageSize: internetSpeed.pageSize,
            sortType: .topYear, // defaultPostSorting,
            showReadPosts: showReadPosts,
            // Don't load from PersistenceRepository directly here, as we'll be reading from file every time the view is initialized, which can happen frequently
            filteredKeywords: [],
            feedType: .aggregateFeed(AppState.main.firstApi, type: .subscribed),
            smallAvatarSize: AppConstants.smallAvatarSize,
            largeAvatarSize: AppConstants.largeAvatarSize,
            urlCache: AppConstants.urlCache
        ))
    }
    
    var body: some View {
        content
            // .background(tilePosts && !isAtTop ? palette.groupedBackground : palette.background)
            .background(tilePosts ? palette.groupedBackground : palette.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarEllipsisMenu {
                    MenuButton(action: BasicAction(
                        isOn: showRead,
                        label: showRead ? "Hide Read" : "Show Read",
                        color: palette.primary,
                        icon: Icons.read
                    ) {
                        showRead = !showRead
                    })
                }
            }
            .onChange(of: tilePosts, initial: true) { _, newValue in
                if newValue {
                    // leading/trailing alignment makes them want to stick to each other, allowing the AppConstants.halfSpacing padding applied below
                    // to push them apart by a sum of AppConstants.standardSpacing
                    columns = [
                        GridItem(.flexible(), spacing: 0, alignment: .trailing),
                        GridItem(.flexible(), spacing: 0, alignment: .leading)
                    ]
                } else {
                    columns = [GridItem(.flexible())]
                }
            }
            .task(id: showRead) {
                do {
                    if showRead {
                        try await postFeedLoader.removeFilter(.read)
                    } else {
                        try await postFeedLoader.addFilter(.read)
                    }
                } catch {
                    handleError(error)
                }
            }
            .task(id: appState.firstApi) {
                do {
                    try await postFeedLoader.refresh(clearBeforeRefresh: true)
                } catch {
                    handleError(error)
                }
            }
            .task(id: appState.firstApi) {
                do {
                    try await postFeedLoader.changeFeedType(to: .aggregateFeed(appState.firstApi, type: .subscribed))
                } catch {
                    handleError(error)
                }
            }
            .refreshable {
                do {
                    try await postFeedLoader.refresh(clearBeforeRefresh: false)
                } catch {
                    handleError(error)
                }
            }
    }
    
    @ViewBuilder
    var content: some View {
        FancyScrollView(isAtTop: $isAtTop) {
            LazyVGrid(columns: columns, spacing: tilePosts ? AppConstants.standardSpacing : 0, pinnedViews: [.sectionHeaders]) {
                Section {} header: {
                    feedHeaderMockup
                }
                
                if !tilePosts { Divider() }
                
                Section {
                    ForEach(postFeedLoader.items, id: \.uid) { post in
                        if !post.read || showRead {
                            VStack(spacing: 0) { // this improves performance O_o
                                NavigationLink(value: NavigationPage.expandedPost(post)) {
                                    FeedPostView(post: .init(post))
                                        .contentShape(.rect)
                                }
                                .buttonStyle(EmptyButtonStyle())
                                if !tilePosts { Divider() }
                            }
                            .padding(.horizontal, tilePosts ? AppConstants.halfSpacing : 0)
                        }
                    }
                } header: {
                    BubblePicker(DummyBubble.allCases, selected: $dummyBubble) { $0.rawValue.capitalized }
                        .background { pickerBackground }
//                        .background {
//                            if !isAtTop {
//                                Material.bar
//                        }
//                        .background {
//                            Group {
//                                if isAtTop {
//                                    Color.clear
//                                } else {
//                                    Material.bar
//                                }
//                            }
//                    }
                } footer: {
                    Group {
                        switch postFeedLoader.loadingState {
                        case .loading:
                            Text("Loading...")
                        case .done:
                            Text("Done")
                        case .idle:
                            Text("Idle")
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
    
    @ViewBuilder
    var pickerBackground: some View {
        if isAtTop {
            EmptyView()
        } else {
            Color.clear
                .background(Material.bar)
        }
    }
    
    @ViewBuilder
    var feedHeaderMockup: some View {
        HStack(alignment: .center, spacing: AppConstants.standardSpacing) {
            Circle()
                .fill(.red)
                .frame(width: 44, height: 44)
                .overlay {
                    Image(systemName: Icons.subscribedFeedFill)
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.white)
                        .frame(width: 22, height: 22)
                }
                .padding(.leading, AppConstants.standardSpacing)
            
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: AppConstants.halfSpacing) {
                    Text("Subscribed")
                        .fontWeight(.bold)
                    
                    Image(systemName: Icons.dropdown)
                        .foregroundStyle(palette.secondary)
                }
                .font(.title2)
                
                Text("Posts from all subscribed communities")
                    .font(.footnote)
                    .foregroundStyle(palette.secondary)
            }
            .frame(height: 44)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    // This is a proof-of-concept; in the real frontend this code will go in InteractionBarView
    @ViewBuilder
    func actionButton(_ action: BasicAction) -> some View {
        Button(action: action.callback ?? {}) {
            Image(systemName: action.barIcon)
                .foregroundColor(action.isOn ? palette.selectedInteractionBarItem : palette.primary)
                .padding(2)
                .background(
                    RoundedRectangle(cornerRadius: AppConstants.tinyItemCornerRadius)
                        .fill(action.isOn ? action.color : .clear)
                )
        }
        .buttonStyle(EmptyButtonStyle())
        .disabled(action.callback == nil)
        .opacity(action.callback == nil ? 0.5 : 1)
    }
}
