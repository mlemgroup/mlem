//
//  FeedsView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-01-07.
//

import Dependencies
import Foundation
import SwiftUI

struct FeedsView: View {
    @Environment(AppState.self) var appState
    
    var body: some View {
        content
            .navigationTitle("Feeds")
    }
    
    var content: some View {
        MinimalPostFeedView(initialFeedProvider: appState.api)
    }
}

struct MinimalPostFeedView: View {
    @Dependency(\.errorHandler) var errorHandler
    
    @Environment(AppState.self) var appState
    
    @State var postTracker: StandardPostTracker
    
    init(initialFeedProvider: any PostFeedProvider) {
        // need to grab some stuff from app storage to initialize with
        @AppStorage("internetSpeed") var internetSpeed: InternetSpeed = .fast
        @AppStorage("upvoteOnSave") var upvoteOnSave = false
        @AppStorage("showReadPosts") var showReadPosts = true
        @AppStorage("defaultPostSorting") var defaultPostSorting: ApiSortType = .hot
        
        self._postTracker = .init(initialValue: .init(
            internetSpeed: internetSpeed,
            sortType: defaultPostSorting,
            showReadPosts: showReadPosts,
            feedType: .aggregateFeed(initialFeedProvider, type: .subscribed)
        ))
    }
    
    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Feeds")
                .fancyTabScrollCompatible()
                .task {
                    await postTracker.loadMoreItems()
                }
                .task(id: appState.actorId) {
                    await postTracker.changeFeedType(to: .aggregateFeed(appState.api, type: .subscribed))
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
    func actionButton(_ action: Action) -> some View {
        Button(action: action.callback ?? { }) {
            Image(systemName: action.barIcon)
                .foregroundColor(action.barIsOn ? .white : .primary)
                .padding(2)
                .background(
                    RoundedRectangle(cornerRadius: AppConstants.tinyItemCornerRadius)
                        .fill(action.barIsOn ? action.color : .clear)
                )
        }
        .buttonStyle(EmptyButtonStyle())
        .disabled(action.callback == nil)
    }
    
    @ViewBuilder
    var content: some View {
        ScrollView {
            LazyVStack {
                ForEach(postTracker.items, id: \.uid) { post in
                    VStack {
                        HStack {
                            actionButton(post.action(forKey: .upvote))
                            actionButton(post.action(forKey: .downvote))
                            actionButton(post.action(forKey: .save))
                            
                            Text(post.title)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                                .foregroundStyle(post.isRead ? .secondary : .primary)
                        }
                        .padding(.horizontal)
                        Divider()
                    }
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
