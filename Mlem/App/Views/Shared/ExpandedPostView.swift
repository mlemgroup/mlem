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
    @Environment(\.dismiss) var dismiss
    
    let post: AnyPost
    @State var comments: [CommentWrapper] = []
    @State var loadingState: LoadingState = .idle
    
    var body: some View {
        ContentLoader(model: post) { post1, _ in
            content(for: post1)
                .task {
                    guard loadingState == .idle else { return }
                    loadingState = .loading
                    do {
                        let comments = try await post1.getComments(page: 1, limit: 50)
                        
                        var output: [CommentWrapper] = []
                        var parent: CommentWrapper?
                        for comment in comments {
                            if comment.depth == 0 {
                                let wrapper = CommentWrapper(comment)
                                output.append(wrapper)
                                parent = wrapper
                            } else if comment.depth > (parent?.comment.depth ?? 0) {
                                parent?.addChild(.init(comment))
                            } else if comment.depth < (parent?.comment.depth ?? 0) {
                                parent = parent?.parent
                                parent?.addChild(.init(comment))
                            }
                        }
                        self.comments = output
                        loadingState = .done
                    } catch {
                        handleError(error)
                    }
                }
        }
    }
    
    func content(for post: any Post1Providing) -> some View {
        FancyScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                LargePostView(post: post, isExpanded: true)
                Divider()
                ForEach(comments) { comment in
                    ForEach(comment.tree()) { child in
                        CommentView(comment: child.comment)
                        Divider()
                    }
                }
            }
        }
    }
}
