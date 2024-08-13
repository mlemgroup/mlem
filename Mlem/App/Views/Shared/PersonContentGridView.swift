//
//  PersonContentGridView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-07-18.
//

import Foundation
import MlemMiddleware
import SwiftUI

struct PersonContentGridView: View {
    @Environment(AppState.self) var appState
    @Setting(\.postSize) var postSize
    
    @State var columns: [GridItem] = [GridItem(.flexible())]
    @State var frameWidth: CGFloat = .zero
    
    var feedLoader: PersonContentFeedLoader
    
    var body: some View {
        content
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
    }
    
    var content: some View {
        LazyVGrid(columns: columns, spacing: postSize.tiled ? Constants.main.standardSpacing : 0) {
            ForEach(feedLoader.items, id: \.hashValue) { item in
                VStack(spacing: 0) { // this improves performance O_o
                    personContentItem(item)
                        .buttonStyle(EmptyButtonStyle())
                    if !postSize.tiled { Divider() }
                }
                .padding(.horizontal, postSize.tiled ? Constants.main.halfSpacing : 0)
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
    
    @ViewBuilder
    func personContentItem(_ personContent: PersonContent) -> some View {
        switch personContent.wrappedValue {
        case let .post(post):
            NavigationLink(value: NavigationPage.expandedPost(post)) {
                FeedPostView(post: post)
            }
        case let .comment(comment):
            NavigationLink(value: NavigationPage.expandedPost(comment.post, commentId: comment.id)) {
                FeedCommentView(comment: comment)
            }
        }
    }
}
