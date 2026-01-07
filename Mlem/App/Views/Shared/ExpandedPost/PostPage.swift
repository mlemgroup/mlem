//
//  PostPage.swift
//  Mlem
//
//  Created by Sjmarf on 27/09/2024.
//

import MlemMiddleware
import SwiftUI
import Theming

struct PostPage: View {
    var body: some View {
        Text("TODO")
    }
    
//    @Environment(\.palette) var palette
//    
//    let post: UnifiedPostModel
//    let scrollTargetedComment: (any CommentStubProviding)?
//    @State var tracker: CommentTreeTracker?
//    
//    init(post: UnifiedPostModel, scrollTargetedComment: (any CommentStubProviding)?) {
//        self.post = post
//        self.scrollTargetedComment = scrollTargetedComment
//        if let post = post.wrappedValue as? any Post {
//            self._tracker = .init(wrappedValue: .init(root: .post(post)))
//        } else {
//            self._tracker = .init()
//        }
//    }
//    
//    var body: some View {
//        ContentLoader(model: post) { proxy in
//            ExpandedPostView(
//                post: proxy.entity,
//                contentLoaderError: proxy.error,
//                isLoading: proxy.isLoading,
//                tracker: tracker,
//                scrollTargetedComment: scrollTargetedComment
//            ) {
//                if let post = post.wrappedValue as? any Post3Providing, !post.crossPosts.isEmpty {
//                    CrossPostListView(post: post)
//                        .padding(.horizontal, Constants.main.standardSpacing)
//                }
//            }
//            .refreshable {
//                _ = await Task { @MainActor in
//                    do {
//                        try await post.refresh(upgradeOperation: nil)
//                        await tracker?.refresh()
//                    } catch {
//                        handleError(error)
//                    }
//                }.value
//            }
//        } upgradeOperation: { model, api in
//            try await model.upgrade(api: api, upgradeOperation: nil)
//            if let post = model.wrappedValue as? any Post {
//                if let tracker {
//                    tracker.root = .post(post)
//                    tracker.loadingState = .idle
//                } else {
//                    tracker = .init(root: .post(post))
//                }
//                Task {
//                    await tracker?.load(ensuringPresenceOf: scrollTargetedComment)
//                }
//            }
//        }
//        .themedGroupedBackground()
//        .onAppear {
//            if post.isUpgraded, let tracker {
//                Task {
//                    await tracker.load(ensuringPresenceOf: scrollTargetedComment)
//                }
//            }
//        }
//    }
}

//#if DEBUG
//    #Preview(traits: .sampleEnvironment(api: .realistic)) {
//        PostPage(post: .init(Post2.mock(.realistic(.showerThoughtPizza))), scrollTargetedComment: nil)
//            .previewNavigationStack(backButtonLabel: "Local")
//            .previewTabBar(selected: .feeds)
//    }
//#endif
