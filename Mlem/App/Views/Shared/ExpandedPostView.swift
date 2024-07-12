//
//  ExpandedPostView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-05-12.
//

import Foundation
import MlemMiddleware
import SwiftUI

struct ExpandedPostView: View {
    @Environment(Palette.self) var palette
    @Environment(AppState.self) var appState
    @Environment(\.dismiss) var dismiss
    
    let post: AnyPost
    @State var showCommentWithId: Int?
    
    @State var comments: [CommentWrapper] = []
    @State var commentsKeyedByActorId: [URL: CommentWrapper] = [:]
    
    @State var loadingState: LoadingState = .idle
    
    var body: some View {
        ContentLoader(model: post) { proxy in
            if let post = proxy.entity {
                let showLoadingSymbol = showCommentWithId == nil || self.post.isUpgraded && loadingState != .loading
                VStack {
                    if showLoadingSymbol {
                        content(for: post)
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
                    if post.api == appState.firstApi {
                        await loadComments(post: post)
                    }
                }
                .onChange(of: post.api.actorId) {
                    Task {
                        loadingState = .idle
                        await loadComments(post: post)
                    }
                }
                .toolbar {
                    if proxy.isLoading || (!comments.isEmpty && comments.first?.api !== post.api) {
                        ProgressView()
                    } else {
                        ToolbarEllipsisMenu(post.menuActions())
                    }
                }
            } else {
                ProgressView()
                    .tint(palette.secondary)
            }
        }
    }
    
    // @ViewBuilder
    func content(for post: any Post1Providing) -> some View {
        ScrollViewReader { proxy in
            FancyScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    LargePostView(post: post, isExpanded: true)
                    Divider()
                    ForEach(comments.tree()) { comment in
                        CommentView(comment: comment, highlight: showCommentWithId == comment.id)
                            .transition(.move(edge: .top).combined(with: .opacity))
                            .zIndex(1000 - Double(comment.depth))
                    }
                }
                .animation(.easeInOut(duration: 1.5), value: showCommentWithId)
            }
            .onAppear {
                if let showCommentWithId {
                    // The scroll destination isn' always accurate. Possibly due to the post image changing
                    // size on load? Using `anchor: .top` would be better here, but `anchor: .center` makes
                    // the inaccuracy less noticeable. See also the comment further up the file.
                    proxy.scrollTo(showCommentWithId, anchor: .center)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.showCommentWithId = nil
                    }
                }
            }
        }
    }
    
    func loadComments(post: any Post) async {
        guard loadingState == .idle else { return }
        loadingState = .loading
        do {
            let newComments = try await post.getComments(sort: .top, page: 1, maxDepth: 8, limit: 50)
            if let first = comments.first, first.api != appState.firstApi {
                resolveCommentTree(comments: newComments)
            } else {
                builtCommentTree(comments: newComments)
            }
            loadingState = .done
        } catch {
            handleError(error)
        }
    }
    
    func builtCommentTree(comments newComments: [Comment2]) {
        var output: [CommentWrapper] = []
        var commentsKeyedById: [Int: CommentWrapper] = [:]
        var commentsKeyedByActorId: [URL: CommentWrapper] = [:]
        
        for comment in newComments {
            let wrapper: CommentWrapper = .init(comment)
            commentsKeyedById[comment.id] = wrapper
            commentsKeyedByActorId[comment.actorId] = wrapper
            if let parentId = comment.parentCommentIds.last {
                commentsKeyedById[parentId]?.addChild(wrapper)
            } else {
                output.append(wrapper)
            }
        }
        comments = output
        self.commentsKeyedByActorId = commentsKeyedByActorId
    }
    
    func resolveCommentTree(comments newComments: [Comment2]) {
        var commentsKeyedById: [Int: CommentWrapper] = [:]
        
        for comment in newComments {
            if let existing = commentsKeyedByActorId[comment.actorId] {
                existing.comment2 = comment
                commentsKeyedById[comment.id] = existing
            } else {
                let wrapper: CommentWrapper = .init(comment)
                commentsKeyedById[comment.id] = wrapper
                commentsKeyedByActorId[comment.actorId] = wrapper
                if let parentId = comment.parentCommentIds.last {
                    if let parent = commentsKeyedById[parentId] {
                        parent.addChild(wrapper)
                    } else {
                        assertionFailure("This should never happen because the API returns comments in order of depth asc.")
                    }
                } else {
                    comments.append(wrapper)
                }
            }
        }
    }
}
