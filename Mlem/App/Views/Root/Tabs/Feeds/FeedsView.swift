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
            .navigationTitle("Feeds")
    }
    
    var content: some View {
        MinimalPostFeedView()
    }
}

struct MinimalPostFeedView: View {
    @Dependency(\.errorHandler) var errorHandler
    
    @Environment(AppState.self) var appState
    
    @State var postTracker: StandardPostTracker
    
    init() {
        // need to grab some stuff from app storage to initialize with
        @AppStorage("internetSpeed") var internetSpeed: InternetSpeed = .fast
        @AppStorage("upvoteOnSave") var upvoteOnSave = false
        @AppStorage("showReadPosts") var showReadPosts = true
        @AppStorage("defaultPostSorting") var defaultPostSorting: ApiSortType = .hot
        
        @Dependency(\.persistenceRepository) var persistenceRepository
        
        _postTracker = .init(initialValue: .init(
            pageSize: internetSpeed.pageSize,
            sortType: defaultPostSorting,
            showReadPosts: showReadPosts,
            filteredKeywords: persistenceRepository.loadFilteredKeywords(),
            feedType: .aggregateFeed(AppState.main.firstApi, type: .subscribed)
        ))
    }
    
    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Feeds")
                .task {
                    if postTracker.items.isEmpty, postTracker.loadingState == .idle {
                        print("Loading initial PostTracker page...")
                        do {
                            try await postTracker.loadMoreItems()
                        } catch {
                            errorHandler.handle(error)
                        }
                    }
                }
                .task(id: appState.firstApi) {
                    do {
                        try await postTracker.changeFeedType(to: .aggregateFeed(appState.firstApi, type: .subscribed))
                    } catch {
                        errorHandler.handle(error)
                    }
                }
                .refreshable {
                    do {
                        try await postTracker.refresh(clearBeforeRefresh: false)
                    } catch {
                        errorHandler.handle(error)
                    }
                }
        }
    }
    
    // This is a proof-of-concept; in the real frontend this code will go in InteractionBarView
    @ViewBuilder
    func actionButton(_ action: BasicAction) -> some View {
        Button(action: action.callback ?? {}) {
            Image(systemName: action.barIcon)
                .foregroundColor(action.isOn ? .white : .primary)
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
    
    @ViewBuilder
    var content: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(postTracker.items, id: \.uid) { post in
                    HStack {
//                        actionButton(post.upvoteAction)
//                        actionButton(post.downvoteAction)
//                        actionButton(post.saveAction)
                        
                        Text(post.title)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            .foregroundStyle(post.isRead ? .secondary : .primary)
                    }
                    .padding(10)
                    .background(Color(uiColor: .systemBackground))
                    .contentShape(.rect)
//                    .contextMenu {
//                        ForEach(post.menuActions.children, id: \.id) { action in
//                            MenuButton(action: action)
//                        }
//                    }
                    Divider()
                }
            }
            
            switch postTracker.loadingState {
            case .loading:
                Text("Loading...")
            case .done:
                Text("Done")
            case .idle:
                Text("Idle")
            }
        }
    }
}
