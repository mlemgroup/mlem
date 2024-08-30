//
//  PersonContentGridView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-07-18.
//

import Foundation
import MlemMiddleware
import SwiftUI

enum PersonContentType {
    case all, posts, comments
}

struct PersonContentGridView: View {
    @Environment(AppState.self) var appState
    @Setting(\.postSize) var postSize
    
    @State var columns: [GridItem] = [GridItem(.flexible())]
    @State var frameWidth: CGFloat = .zero
    
    var feedLoader: PersonContentFeedLoader
    @Binding var contentType: PersonContentType
    
    var items: [PersonContent] {
        switch contentType {
        case .all: feedLoader.items
        case .posts: feedLoader.posts
        case .comments: feedLoader.comments
        }
    }
    
    var loadingState: LoadingState {
        switch contentType {
        case .all: feedLoader.loadingState
        case .posts: feedLoader.postLoadingState
        case .comments: feedLoader.commentLoadingState
        }
    }
    
    var body: some View {
        content
            .loadFeed(feedLoader)
            .widthReader(width: $frameWidth)
            .environment(\.parentFrameWidth, frameWidth)
            .onChange(of: postSize, initial: true) { _, newValue in
                if newValue.tiled {
                    // leading/trailing alignment makes them want to stick to each other, allowing the Constants.main.halfSpacing padding applied below
                    // to push them apart by a sum of Constants.main.standardSpacing
                    columns = [
                        GridItem(.flexible(), spacing: 0, alignment: .trailing),
                        GridItem(.flexible(), spacing: 0, alignment: .leading)
                    ]
                } else if columns.count > 1 {
                    // Only trigger if not already 1 column to avoid causing unnecessary view update
                    columns = [GridItem(.flexible())]
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .secondaryAction) {
                    Section {
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
            }
    }
    
    var content: some View {
        VStack(spacing: 0) {
            LazyVGrid(columns: columns, spacing: postSize.tiled ? Constants.main.standardSpacing : 0) {
                ForEach(items, id: \.hashValue) { item in
                    VStack(spacing: 0) { // this improves performance O_o
                        personContentItem(item)
                            .buttonStyle(EmptyButtonStyle())
                        if !postSize.tiled { PaletteDivider() }
                    }
                    .padding(.horizontal, postSize.tiled ? Constants.main.halfSpacing : 0)
                    .onAppear {
                        do {
                            try feedLoader.loadIfThreshold(item, asChild: contentType != .all)
                        } catch {
                            // TODO: is postFeedLoader.loadIfThreshold throws 400, this line is not executed
                            handleError(error)
                        }
                    }
                }
            }
            
            EndOfFeedView(loadingState: loadingState, viewType: .hobbit)
        }
    }
    
    @ViewBuilder
    func personContentItem(_ personContent: PersonContent) -> some View {
        switch personContent.wrappedValue {
        case let .post(post):
            NavigationLink(value: NavigationPage.expandedPost(post)) {
                FeedPostView(post: post)
            }
        case let .comment(comment):
            NavigationLink(value: NavigationPage.expandedPost(comment.post, commentActorId: comment.actorId)) {
                FeedCommentView(comment: comment)
            }
        }
    }
}
