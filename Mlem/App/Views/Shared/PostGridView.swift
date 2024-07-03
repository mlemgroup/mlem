//
//  PostFeedView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-06-29.
//

import Foundation
import MlemMiddleware
import SwiftUI

/// Renders the content of a given StandardPostFeedLoader. Responsible solely for post layout and triggering loading; scrolling, handling feed type
/// changes, rendering toolbar items, etc. should be handled by the parent view.
struct PostGridView: View {
    @AppStorage("beta.tilePosts") var tilePosts: Bool = false
    @AppStorage("feed.showRead") var showRead: Bool = true
    
    @Environment(AppState.self) var appState
    
    @State var columns: [GridItem] = [GridItem(.flexible())]
    
    let postFeedLoader: StandardPostFeedLoader
    
    var body: some View {
        content
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
    }
    
    var content: some View {
        LazyVGrid(columns: columns, spacing: tilePosts ? AppConstants.standardSpacing : 0) {
            // Section lets the header and loading footer play nice regardless of column count
            Section {
                if !tilePosts { Divider() }
                
                ForEach(postFeedLoader.items, id: \.hashValue) { post in
                    if !post.read || showRead {
                        VStack(spacing: 0) { // this improves performance O_o
                            NavigationLink(value: NavigationPage.expandedPost(post)) {
                                FeedPostView(post: post)
                            }
                            .buttonStyle(EmptyButtonStyle())
                            if !tilePosts { Divider() }
                        }
                        .padding(.horizontal, tilePosts ? AppConstants.halfSpacing : 0)
                        .onAppear {
                            do {
                                try postFeedLoader.loadIfThreshold(post)
                            } catch {
                                handleError(error)
                            }
                        }
                    }
                }
            } header: {
                header
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
    
    @ViewBuilder
    var header: some View {
        switch postFeedLoader.feedType {
        case let .aggregateFeed(_, type):
            switch type {
            case .all: FeedHeaderView(feedDescription: .all, actions: headerMenuActions)
            case .local: FeedHeaderView(feedDescription: .local, actions: headerMenuActions)
            case .subscribed: FeedHeaderView(feedDescription: .subscribed, actions: headerMenuActions)
            case .moderatorView: FeedHeaderView(feedDescription: .moderated)
            }
        case .community: FeedHeaderView(feedDescription: .subscribed) // TODO:
        }
    }
}
