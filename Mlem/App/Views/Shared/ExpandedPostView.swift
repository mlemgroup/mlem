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
    
    let tracker: ExpandedPostTracker = .init()
    
    @State var commentResolveLoading: Bool = false
    
    var body: some View {
        ContentLoader(model: post) { proxy in
            if let post = proxy.entity {
                let showLoadingSymbol = showCommentWithId == nil || (self.post.isUpgraded && tracker.loadingState != .loading)
                VStack {
                    if showLoadingSymbol {
                        content(for: post)
                            .externalApiWarning(entity: post, isLoading: proxy.isLoading)
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
                        post.markRead()
                        await tracker.load(post: post)
                    }
                }
                .onChange(of: post.api) {
                    tracker.resolveComments(post: post)
                }
                .toolbar {
                    if proxy.isLoading {
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
        .environment(tracker)
    }
    
    @ViewBuilder
    func content(for post: any Post1Providing) -> some View {
        ScrollViewReader { proxy in
            FancyScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    LargePostView(post: post, isExpanded: true)
                    Divider()
                    ForEach(tracker.comments.tree()) { comment in
                        CommentView(comment: comment, highlight: showCommentWithId == comment.id)
                            .transition(.move(edge: .top).combined(with: .opacity))
                            .zIndex(1000 - Double(comment.depth))
                    }
                }
                .animation(.easeInOut(duration: 0.4), value: showCommentWithId)
            }
            .onAppear {
                if let showCommentWithId {
                    // The scroll destination isn't always accurate. Possibly due to the post image changing
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
}
