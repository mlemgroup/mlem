//
//  ExpandedPostView.swift
//  Mlem
//
//  Created by Sjmarf on 03/09/2024.
//

import MlemMiddleware
import SwiftUI

struct ExpandedPostView: View {
    @Environment(Palette.self) var palette
    @Environment(AppState.self) var appState
    @Environment(\.dismiss) var dismiss
    
    let post: AnyPost
    @State var tracker: CommentTreeTracker?
    let highlightedComment: (any CommentStubProviding)?
    
    var body: some View {
        ContentLoader(model: post) { proxy in
            if let post = proxy.entity, let tracker {
                let showLoadingSymbol = highlightedComment == nil || (post is any Post2Providing && tracker.loadingState == .done)
                VStack {
                    if showLoadingSymbol {
                        CommentTreeView(
                            post: post,
                            tracker: tracker,
                            scrollToCommentWithActorId: highlightedComment?.actorId,
                            isLoading: proxy.isLoading
                        )
                        .externalApiWarning(entity: post, isLoading: proxy.isLoading)
                        .geometryGroup()
//                        .transition(.asymmetric(insertion: .opacity, removal: .identity))
                    } else {
                        // We *could* show the post here, but we'd need to scroll down as soon as the comments load.
                        // So, show a ProgressView instead (cleaner UX).
                        ProgressView()
                            .tint(.secondary)
//                            .transition(.asymmetric(insertion: .identity, removal: .opacity))
                    }
                }
//                .animation(.default, value: showLoadingSymbol)
                .task {
                    if post.api == appState.firstApi, tracker.loadingState == .idle {
                        post.markRead()
                        await load(tracker: tracker)
                    }
                }
            } else {
                ProgressView()
                    .tint(palette.secondary)
            }
        } upgradeOperation: { model, api in
            try await model.upgrade(api: api, upgradeOperation: nil)
            if let post = model.wrappedValue as? any Post {
                if let tracker {
                    tracker.root = .post(post)
                    tracker.loadingState = .idle
                    await load(tracker: tracker)
                } else {
                    tracker = .init(root: .post(post))
                }
            }
        }
        .background(palette.background)
    }
    
    func load(tracker: CommentTreeTracker) async {
        if let highlightedComment {
            await tracker.load(ensuringPresenceOf: highlightedComment)
        } else {
            await tracker.load()
        }
    }
}
