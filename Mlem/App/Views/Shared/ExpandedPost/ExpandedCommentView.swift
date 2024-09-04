//
//  ExpandedCommentView.swift
//  Mlem
//
//  Created by Sjmarf on 03/09/2024.
//

import MlemMiddleware
import SwiftUI

struct ExpandedCommentView: View {
    @Environment(Palette.self) var palette
    @Environment(AppState.self) var appState
    @Environment(\.dismiss) var dismiss
    
    let comment: AnyComment
    let showCommentWithActorId: URL?
    
    @State var tracker: CommentTreeTracker?
    @State private var post: (any Post)?
    
    init(comment: AnyComment, showCommentWithActorId: URL?) {
        self.comment = comment
        self.showCommentWithActorId = showCommentWithActorId
        if let post = comment.wrappedValue.post_ {
            self.post = post
        }
    }
    
    var body: some View {
        ContentLoader(model: comment) { proxy in
            if let comment = proxy.entity, let tracker {
                let showLoadingSymbol = (
                    showCommentWithActorId == nil || (comment is any Comment2Providing && tracker.loadingState != .loading
                    )) && post != nil
                VStack {
                    if showLoadingSymbol, let post {
                        CommentTreeView(
                            post: post,
                            tracker: tracker,
                            highlightCommentWithActorId: comment.actorId,
                            scrollToCommentWithActorId: showCommentWithActorId,
                            isLoading: proxy.isLoading,
                            depthOffset: max(0, comment.depth - 1)
                        ) {
                            HStack {
                                Button("Show Context", systemImage: "text.insert") {}
                                Button(
                                    "Go to Post",
                                    systemImage: Icons.posts
                                ) {}
                            }
                            .buttonStyle(ViewButtonStyle())
                            .padding(Constants.main.standardSpacing)
                            Divider()
                        }
                        .externalApiWarning(entity: comment, isLoading: proxy.isLoading)
                        .transition(.opacity)
                    } else {
                        // We *could* show the post here, but we'd need to scroll down as soon as the comments load.
                        // So, show a ProgressView instead (cleaner UX).
                        ProgressView()
                            .tint(.secondary)
                            .transition(.opacity)
                        // TODO: prefetch post image in an `.onChange` here?
                        // This could alleviate the `scrollTo` inaccuracy mentioned further down,
                        // As the post won't change size if the image is able to load in time.
                        // Theoretically we'd also need to do this with comment images, but
                        // unfortunately we don't have time for that because the comments should be
                        // shown as soon as they load.
                    }
                }
                .animation(.default, value: showLoadingSymbol)
                .task {
                    if comment.api == appState.firstApi, tracker.loadingState == .idle {
                        await tracker.load()
                    }
                }
            } else {
                ProgressView()
                    .tint(palette.secondary)
            }
        } upgradeOperation: { model, api in
            try await model.upgrade(api: api, upgradeOperation: nil)
            if let comment = model.wrappedValue as? any Comment {
                if let tracker {
                    tracker.root = .comment(comment, parentCount: 1)
                    tracker.loadingState = .idle
                    await tracker.load()
                } else {
                    tracker = .init(root: .comment(comment, parentCount: 1))
                }
                if let post = comment.post_, self.post?.api != post.api {
                    self.post = post
                }
            }
        }
        .background(palette.background)
        .task(id: post?.hashValue) {
            do {
                if let post, !(post is any Post2Providing) {
                    self.post = try await post.upgrade()
                }
            } catch {
                handleError(error)
            }
        }
    }
}

private struct ViewButtonStyle: ButtonStyle {
    @Environment(Palette.self) var palette
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding(.vertical, 4)
            .frame(maxWidth: .infinity)
            .background(palette.secondaryBackground, in: .capsule)
            .font(.headline)
            .fontWeight(.semibold)
    }
}
