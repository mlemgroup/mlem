//
//  NEW PostFeedView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-01-13.
//

import Foundation
import SwiftUI

struct NewPostFeedView: View {
    @AppStorage("shouldShowPostCreator") var shouldShowPostCreator: Bool = true
    
    @ObservedObject var postTracker: StandardPostTracker
    
    var body: some View {
        if postTracker.items.isEmpty {
            Text("No posts!")
        } else {
            LazyVStack(spacing: 0) {
                ForEach(postTracker.items, id: \.uid) { feedPost(for: $0) }
                EndOfFeedView(loadingState: postTracker.loadingState, viewType: .hobbit)
            }
        }
    }
    
    @ViewBuilder
    private func feedPost(for post: PostModel) -> some View {
        VStack(spacing: 0) {
            // TODO: reenable nav
            FeedPost(
                post: post,
                community: post.community,
                showPostCreator: shouldShowPostCreator,
                showCommunity: false // TODO: show community
            )
            // .onAppear { postTracker.loadIfThreshold(post) }
            Divider()
        }
        .buttonStyle(EmptyButtonStyle()) // Make it so that the link doesn't mess with the styling
    }
}
