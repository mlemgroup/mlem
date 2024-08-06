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
    @AppStorage("post.size") var postSize: PostSize = .large
    @AppStorage("feed.showRead") var showRead: Bool = true
    
    @Environment(AppState.self) var appState
    
    @State var columns: [GridItem] = [GridItem(.flexible())]
    @State var frameWidth: CGFloat = .zero
    
    let postFeedLoader: CorePostFeedLoader
    
    var body: some View {
        content
            .widthReader(width: $frameWidth)
            .environment(\.parentFrameWidth, frameWidth)
            .onChange(of: postSize, initial: true) { _, newValue in
                if newValue.tiled {
                    // leading/trailing alignment makes them want to stick to each other, allowing the AppConstants.halfSpacing padding applied below
                    // to push them apart by a sum of AppConstants.standardSpacing
                    
                    // Avoid causing unnecessary view update
                    if columns.count == 1 {
                        columns = [
                            GridItem(.flexible(), spacing: 0, alignment: .trailing),
                            GridItem(.flexible(), spacing: 0, alignment: .leading)
                        ]
                    }
                } else {
                    // Avoid causing unnecessary view update
                    if columns.count == 2 {
                        columns = [GridItem(.flexible())]
                    }
                }
            }
    }
    
    var content: some View {
        LazyVGrid(columns: columns, spacing: postSize.tiled ? AppConstants.standardSpacing : 0) {
            ForEach(postFeedLoader.items, id: \.hashValue) { post in
                if !post.read || showRead, !post.creator.blocked, !post.community.blocked, !post.hidden {
                    VStack(spacing: 0) { // this improves performance O_o
                        NavigationLink(value: NavigationPage.expandedPost(post)) {
                            FeedPostView(post: post)
                        }
                        .buttonStyle(EmptyButtonStyle())
                        if !postSize.tiled { Divider() }
                    }
                    .padding(.horizontal, postSize.tiled ? AppConstants.halfSpacing : 0)
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
