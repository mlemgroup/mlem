//
//  CommentBodyView.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-03.
//

import Foundation
import SwiftUI

struct CommentBodyView: View {
    @AppStorage("shouldShowUserServerInComment") var shouldShowUserServerInComment: Bool = false
    
    let commentView: APICommentView
    let isCollapsed: Bool
    let showPostContext: Bool
    let showCommentCreator: Bool
    let commentorLabel: String
    let menuFunctions: [MenuFunction]

    init(commentView: APICommentView,
         isCollapsed: Bool,
         showPostContext: Bool,
         showCommentCreator: Bool,
         menuFunctions: [MenuFunction]) {
        self.commentView = commentView
        self.isCollapsed = isCollapsed
        self.showPostContext = showPostContext
        self.showCommentCreator = showCommentCreator
        self.menuFunctions = menuFunctions
        
        let commentor = commentView.creator
        let publishedAgo: String = getTimeIntervalFromNow(date: commentView.comment.published)
        commentorLabel = "Last updated \(publishedAgo) ago by \(commentor.displayName ?? commentor.name)"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.postAndCommentSpacing) {
            // TEMPORARILY DISABLED: hiding comment creator--doesn't appear to be used anywhere in the code?
            // if showCommentCreator {
            HStack {
                UserProfileLink(
                    user: commentView.creator,
                    serverInstanceLocation: shouldShowUserServerInComment ? .bottom : .disabled,
                    postContext: commentView.post,
                    commentContext: commentView.comment
                )
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(commentorLabel)
                .foregroundColor(.secondary)
                
                Spacer()
                
                EllipsisMenu(size: 24, menuFunctions: menuFunctions)
            }
            // }
            
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
