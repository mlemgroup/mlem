//
//  PostFeedView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-06-29.
//

import Foundation
import MlemMiddleware
import SwiftUI

/// Renders the content of a given StandardPostFeedLoader and adds a toolbar menu with the standard post feed controls. Additional toolbar actions
/// should be handled by using ToolbarItemGroup(placement: .secondaryAction) on the parent view.
/// This view handles:
/// - Post layout
/// - Loading
/// - Default toolbar menu actions (show/hide read, post size)
/// Scrolling, handling feed type changes, header, footer, etc. should be handled by the parent view
struct PostGridView: View {
    @Setting(\.postSize) var postSize
    @Setting(\.showReadInFeed) var showRead
    
    @Environment(AppState.self) var appState
    @Environment(Palette.self) var palette
    
    @Environment(\.communityContext) var communityContext
    
    @State var columns: [GridItem] = [GridItem(.flexible())]
    @State var frameWidth: CGFloat = .zero
    @State var bottomAppearedPostIndex: Int = -1
    
    let postFeedLoader: CorePostFeedLoader

    init(postFeedLoader: CorePostFeedLoader, actions: [any Action]? = nil) {
        self.postFeedLoader = postFeedLoader
    }
    
    var body: some View {
        content
            .widthReader(width: $frameWidth)
            .environment(\.parentFrameWidth, frameWidth)
            .loadFeed(postFeedLoader)
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
            .onChange(of: postSize, initial: true) { _, newValue in
                if newValue.tiled {
                    // leading/trailing alignment makes them want to stick to each other, allowing the Constants.main.halfSpacing padding applied below
                    // to push them apart by a sum of Constants.main.standardSpacing
                    
                    // Avoid causing unnecessary view update
                    if columns.count == 1 {
                        columns = [
                            GridItem(.flexible(), spacing: 0, alignment: .trailing),
                            GridItem(.flexible(), spacing: 0, alignment: .leading)
                        ]
                    }
                } else if columns.count > 1 {
                    // Only trigger if not already 1 column to avoid causing unnecessary view update
                    columns = [GridItem(.flexible())]
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .secondaryAction) {
                    Section {
                        standardMenu
                    }
                }
            }
    }
    
    var content: some View {
        VStack(spacing: 0) {
            LazyVGrid(columns: columns, spacing: postSize.tiled ? Constants.main.standardSpacing : 0) {
                ForEach(Array(postFeedLoader.items.enumerated()), id: \.element.hashValue) { index, post in
                    if !post.creator.blocked, !post.community.blocked, !post.hidden {
                        VStack(spacing: 0) { // this improves performance O_o
                            NavigationLink(value: NavigationPage.expandedPost(post, communityContext: communityContext)) {
                                FeedPostView(post: post)
                            }
                            .buttonStyle(EmptyButtonStyle())
                            if !postSize.tiled { Divider() }
                        }
                        .markReadOnScroll(
                            index: index,
                            post: post,
                            postFeedLoader: postFeedLoader, bottomAppearedItemIndex: $bottomAppearedPostIndex
                        )
                        .padding(.horizontal, postSize.tiled ? Constants.main.halfSpacing : 0)
                        .onAppear {
                            do {
                                try postFeedLoader.loadIfThreshold(post)
                            } catch {
                                // TODO: if postFeedLoader.loadIfThreshold throws 400, this line is not executed
                                handleError(error)
                            }
                        }
                    }
                }
            }
        
            EndOfFeedView(loadingState: postFeedLoader.loadingState, viewType: .hobbit)
        }
    }
    
    @ViewBuilder
    var standardMenu: some View {
        Button("\(showRead ? "Hide" : "Show") Read", systemImage: Icons.read) {
            showRead = !showRead
        }
        
        Menu {
            Picker("Post Size", selection: $postSize) {
                ForEach(PostSize.allCases, id: \.self) { item in
                    Label(item.label.key, systemImage: item.icon(filled: postSize == item))
                }
            }
        } label: {
            Label("Post Size", systemImage: Icons.postSizeSetting)
        }
    }
}
