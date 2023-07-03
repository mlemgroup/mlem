//
//  CommentBodyView.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-03.
//

import Foundation
import SwiftUI

struct CommentBodyView: View {
    let commentView: APICommentView
    let isCollapsed: Bool
    let showPostContext: Bool
    
    var body: some View {
        VStack(spacing: AppConstants.postAndCommentSpacing) {
            // comment text or placeholder
            if commentView.comment.deleted {
                Text("Comment was deleted")
                    .italic()
                    .foregroundColor(.secondary)
            } else if commentView.comment.removed {
                Text("Comment was removed")
                    .italic()
                    .foregroundColor(.secondary)
            } else if !isCollapsed {
                MarkdownView(text: commentView.comment.content, isNsfw: commentView.post.nsfw)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
            }

            // embedded post
            if showPostContext {
                EmbeddedPost(
                    community: commentView.community,
                    post: commentView.post
                )
            }
        }
    }
}
