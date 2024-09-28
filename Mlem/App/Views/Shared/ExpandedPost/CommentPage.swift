//
//  CommentPage.swift
//  Mlem
//
//  Created by Sjmarf on 27/09/2024.
//

import MlemMiddleware
import SwiftUI

struct CommentPage: View {
    @Environment(NavigationLayer.self) var navigation
    @Environment(Palette.self) private var palette
    
    let comment: AnyComment
    @State var tracker: CommentTreeTracker?
    
    @State var post: Post3?
    
    init(comment: AnyComment) {
        self.comment = comment
        if let comment = comment.wrappedValue as? any Comment {
            self._tracker = .init(wrappedValue: .init(root: .comment(comment, parentCount: 1)))
        } else {
            self._tracker = .init()
        }
    }
    
    var body: some View {
        ContentLoader(model: comment) { proxy in
            let post: (any Post)? = post ?? proxy.entity?.post_
            ExpandedPostView(
                post: post,
                isLoading: proxy.isLoading,
                tracker: $tracker,
                highlightedComment: proxy.entity,
                scrollTargetedComment: proxy.entity
            ) {
                if let post {
                    HStack(spacing: Constants.main.standardSpacing) {
                        if tracker?.comments.first?.depth != 0 {
                            Button {
                                if let comment = comment.wrappedValue as? any Comment {
                                    tracker?.root = .comment(comment, parentCount: currentDepth + 1)
                                    Task {
                                        await tracker?.refresh()
                                    }
                                }
                            } label: {
                                HStack {
                                    Text("Show Parent")
                                    if tracker?.loadingState == .loading {
                                        ProgressView()
                                    } else {
                                        Image(systemName: "chevron.up")
                                    }
                                }
                                .animation(.easeOut(duration: 0.1), value: tracker?.loadingState == .loading)
                            }
                        }
                        Button {
                            navigation.push(.post(.init(post)))
                        } label: {
                            HStack {
                                Text("View All")
                                Image(systemName: Icons.forward)
                            }
                        }
                    }
                    .buttonStyle(.capsule)
                    .padding(.horizontal, Constants.main.standardSpacing)
                }
            }
            .refreshable {
                _ = await Task {
                    do {
                        await tracker?.refresh()
                    } catch {
                        handleError(error)
                    }
                }.value
            }
        } upgradeOperation: { model, api in
            try await model.upgrade(api: api, upgradeOperation: nil)
            if let comment = model.wrappedValue as? any Comment {
                if let tracker {
                    tracker.root = .comment(comment, parentCount: 1)
                    tracker.loadingState = .idle
                    Task {
                        await tracker.load()
                    }
                } else {
                    tracker = .init(root: .comment(comment, parentCount: 1))
                }
            }
        }
        .background(palette.groupedBackground)
        .onChange(of: comment.wrappedValue.postId_, initial: true) {
            if let postId = comment.wrappedValue.postId_ {
                Task {
                    do {
                        post = try await comment.wrappedValue.api.getPost(id: postId)
                    } catch {
                        handleError(error)
                    }
                }
            }
        }
    }
    
    var currentDepth: Int {
        switch tracker?.root {
        case let .comment(_, currentDepth): currentDepth
        default: 0
        }
    }
}
