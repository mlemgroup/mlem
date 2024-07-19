//
//  UserContentGridView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-07-18.
//

import Foundation
import MlemMiddleware
import SwiftUI

struct UserContentGridView: View {
    @AppStorage("beta.tilePosts") var tilePosts: Bool = false
    
    @Environment(AppState.self) var appState
    
    @State var columns: [GridItem] = [GridItem(.flexible())]
    
    var feedLoader: any FeedLoading<UserContent>
    
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
            ForEach(feedLoader.items, id: \.hashValue) { item in
                VStack(spacing: 0) { // this improves performance O_o
                    userContentItem(item)
                        .buttonStyle(EmptyButtonStyle())
                    if !tilePosts { Divider() }
                }
                .padding(.horizontal, tilePosts ? AppConstants.halfSpacing : 0)
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
    func userContentItem(_ userContent: UserContent) -> some View {
        switch userContent.wrappedValue {
        case let .post(post):
            NavigationLink(value: NavigationPage.expandedPost(post)) {
                FeedPostView(post: post)
            }
        case let .comment(comment):
            Text(comment.content)
        }
    }
}
