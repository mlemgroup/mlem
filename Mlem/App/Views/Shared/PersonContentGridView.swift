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
    enum FeedLoaderType {
        case dualSourceMixed(StandardFeedLoader<PersonContent>)
        case post(StandardFeedLoader<Post2>)
        case comment(StandardFeedLoader<Comment2>)
        case singleSourceMixed(SingleSourceMixedFeedLoader, contentType: PersonContentType)

        var items: [PersonContent] {
            switch self {
            case let .dualSourceMixed(feedLoader): feedLoader.items
            case let .post(feedLoader): feedLoader.items.map { .init(wrappedValue: .post($0)) }
            case let .comment(feedLoader): feedLoader.items.map { .init(wrappedValue: .comment($0)) }
            case let .singleSourceMixed(feedLoader, contentType): feedLoader.itemsForType(contentType)
            }
        }
        
        var loadingState: FeedLoadingState {
            switch self {
            case let .singleSourceMixed(feedLoader, contentType): feedLoader.loadingStateForType(contentType)
            default: feedLoading.loadingState
            }
        }
        
        var feedLoading: any FeedLoading {
            switch self {
            case let .dualSourceMixed(feedLoader): feedLoader
            case let .post(feedLoader): feedLoader
            case let .comment(feedLoader): feedLoader
            case let .singleSourceMixed(feedLoader, _): feedLoader
            }
        }
        
        func loadIfThreshold(_ item: PersonContent) throws {
            switch self {
            case let .dualSourceMixed(feedLoader): try feedLoader.loadIfThreshold(item)
            case let .post(feedLoader):
                switch item.wrappedValue {
                case let .post(post):
                    try feedLoader.loadIfThreshold(post)
                default:
                    assertionFailure()
                }
            case let .comment(feedLoader):
                switch item.wrappedValue {
                case let .comment(comment):
                    try feedLoader.loadIfThreshold(comment)
                default:
                    assertionFailure()
                }
            case let .singleSourceMixed(feedLoader, contentType):
                try feedLoader.loadIfThreshold(item, asChild: contentType != .all)
            }
        }
    }
    
    @Environment(AppState.self) var appState
    @Setting(\.post_size) var postSize
    @Setting(\.behavior_infiniteScroll) var infiniteScroll
    
    @State var columns: [GridItem] = [GridItem(.flexible())]
    @State var frameWidth: CGFloat = .zero
    
    var feedLoader: FeedLoaderType
    var contentType: PersonContentType
    
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
        switch contentType {
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
