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
    let scrollTargetedComment: (any CommentStubProviding)?
    @State var tracker: CommentTreeTracker?
    
    init(post: AnyPost, scrollTargetedComment: (any CommentStubProviding)?) {
        self.post = post
        self.scrollTargetedComment = scrollTargetedComment
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
                scrollTargetedComment: scrollTargetedComment
            ) {
                if let post = post.wrappedValue as? any Post3Providing, !post.crossPosts.isEmpty {
                    CrossPostListView(post: post)
                        .padding(.horizontal, Constants.main.standardSpacing)
                }
            }
            .refreshable {
                _ = await Task {
                    do {
                        try await post.refresh(upgradeOperation: nil)
                        await tracker?.refresh()
                    } catch {
                        handleError(error)
                    }
                }.value
            }
        } upgradeOperation: { model, api in
            try await model.upgrade(api: api, upgradeOperation: nil)
            if let post = model.wrappedValue as? any Post {
                if let tracker {
                    tracker.root = .post(post)
                    tracker.loadingState = .idle
                    Task {
                        await tracker.load(ensuringPresenceOf: scrollTargetedComment)
                    }
                } else {
                    tracker = .init(root: .post(post))
                }
            }
        }
        .background(palette.groupedBackground)
    }
}
