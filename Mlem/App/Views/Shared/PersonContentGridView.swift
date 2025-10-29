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
    @Setting(\.post_size) var postSize
    @Setting(\.behavior_infiniteScroll) var infiniteScroll
    
    @State var columns: [GridItem] = [GridItem(.flexible())]
    @State var frameWidth: CGFloat = .zero
    
    var feedLoader: FeedLoaderType
    
    var body: some View {
        content
            .loadFeed(feedLoader.feedLoading)
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
            .toolbar { FeedToolbarOptions() }
    }
    
    @ViewBuilder
    var content: some View {
        let items = feedLoader.items
        VStack(spacing: 0) {
            LazyVGrid(columns: columns, spacing: spacing) {
                ForEach(items, id: \.hashValue) { item in
                    if !item.shouldHideInFeed {
                        personContentItem(item)
                            .buttonStyle(.empty)
                            .padding(.horizontal, postSize.tiled ? Constants.main.halfSpacing : 10)
                            .onAppear {
                                do {
                                    try feedLoader.loadIfThreshold(item)
                                } catch {
                                    // TODO: is postFeedLoader.loadIfThreshold throws 400, this line is not executed
                                    handleError(error)
                                }
                            }
                    }
                }
            }
            .quickSwipeCornerRadius(postSize.cornerRadius)
            .quickSwipeIconSize(postSize.quickSwipeIconSize)
            .quickSwipeThresholds(postSize.quickSwipeThresholds)
            .animation(.easeOut(duration: 0.1), value: items.isEmpty)
            EndOfFeedView(loadingState: feedLoader.loadingState, viewType: .hobbit)
        }
    }
    
    var spacing: CGFloat {
        switch feedLoader.type {
        case .all, .comments:
            postSize.sectionSpacing
        case .posts:
            postSize.sectionSpacing
        }
    }
    
    @ViewBuilder
    func personContentItem(_ personContent: PersonContent) -> some View {
        switch personContent.wrappedValue {
        case let .post(post):
            NavigationLink(.post(post)) {
                FeedPostView(post: post)
            }
        case let .comment(comment):
            NavigationLink(.comment(comment)) {
                FeedCommentView(comment: comment)
            }
        }
    }
}
