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
    @Environment(\.dismiss) var dismiss
    
    let post: AnyPost
    @State var comments: [CommentWrapper] = []
    @State var loadingState: LoadingState = .idle
    
    var body: some View {
        ContentLoader(model: post) { proxy in
            if let post = proxy.entity {
                content(for: post)
                    .task {
                        guard loadingState == .idle else { return }
                        loadingState = .loading
                        do {
                            let comments = try await post.getComments(sort: .top, page: 1, maxDepth: 8, limit: 50)
                            
                            var output: [CommentWrapper] = []
                            var keyedById: [Int: CommentWrapper] = [:]
                            
                            for comment in comments {
                                let wrapper: CommentWrapper = .init(comment)
                                keyedById[comment.id] = wrapper
                                if let parentId = comment.parentCommentIds.last {
                                    keyedById[parentId]?.addChild(wrapper)
                                } else {
                                    output.append(wrapper)
                                }
                            }
                            self.comments = output
                            loadingState = .done
                        } catch {
                            handleError(error)
                        }
                    }
            } else {
                ProgressView()
                    .tint(palette.secondary)
            }
        }
    }
    
    @ViewBuilder
    func content(for post: any Post1Providing) -> some View {
        FancyScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                LargePostView(post: post, isExpanded: true)
                Divider()
                ForEach(comments.reduce([]) { $0 + $1.tree() }) { comment in
                    CommentView(comment: comment)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .zIndex(1000 - Double(comment.depth))
                }
            }
        }
    }
}
