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
/// changes, header, footer, rendering toolbar items, etc. should be handled by the parent view.
struct PostGridView: View {
    @AppStorage("beta.tilePosts") var tilePosts: Bool = false
    @AppStorage("feed.showRead") var showRead: Bool = true
    
    @Environment(AppState.self) var appState
    
    @State var columns: [GridItem] = [GridItem(.flexible())]
    
    let postFeedLoader: AggregatePostFeedLoader
    
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
            ForEach(postFeedLoader.items, id: \.hashValue) { post in
                if !post.read || showRead, !post.creator.blocked, !post.community.blocked, !post.hidden {
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
                            // TODO: is postFeedLoader.loadIfThreshold throws 400, this line is not executed
                            handleError(error)
                        }
                    }
                }
            }
        }
    }
}
