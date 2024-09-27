//
//  PostPage.swift
//  Mlem
//
//  Created by Sjmarf on 27/09/2024.
//

import MlemMiddleware
import SwiftUI

struct PostPage: View {
    @Environment(Palette.self) private var palette
    
    let post: AnyPost
    let highlightedComment: (any CommentStubProviding)?
    @State var tracker: CommentTreeTracker?
    
    init(post: AnyPost, highlightedComment: (any CommentStubProviding)?) {
        self.post = post
        self.highlightedComment = highlightedComment
        if let post = post.wrappedValue as? any Post {
            self._tracker = .init(wrappedValue: .init(root: .post(post)))
        } else {
            self._tracker = .init()
        }
    }
    
    var body: some View {
        ContentLoader(model: post) { proxy in
            ExpandedPostView(
                post: proxy.entity,
                isLoading: proxy.isLoading,
                tracker: $tracker,
                highlightedComment: highlightedComment
            ) {
                if let post = post.wrappedValue as? any Post3Providing, !post.crossPosts.isEmpty {
                    CrossPostListView(post: post)
                        .padding(.horizontal, Constants.main.standardSpacing)
                }
            }
        } upgradeOperation: { model, api in
            try await model.upgrade(api: api, upgradeOperation: nil)
            if let post = model.wrappedValue as? any Post {
                if let tracker {
                    tracker.root = .post(post)
                    tracker.loadingState = .idle
                    Task {
                        await tracker.load(ensuringPresenceOf: highlightedComment)
                    }
                } else {
                    tracker = .init(root: .post(post))
                }
            }
        }
        .background(palette.groupedBackground)
    }
}
