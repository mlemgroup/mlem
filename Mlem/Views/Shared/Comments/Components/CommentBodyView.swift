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
    @AppStorage("compactComments") var compactComments: Bool = false
    @AppStorage("showCommentDownvotesSeparately") var showCommentDownvotesSeparately: Bool = false
    
    let commentView: CommentModel
    let isCollapsed: Bool
    let showPostContext: Bool
    let commentorLabel: String
    let menuFunctions: [MenuFunction]
    
    var myVote: ScoringOperation { commentView.votes.myVote }
    
    var serverInstanceLocation: ServerInstanceLocation {
        if shouldShowUserServerInComment {
            return .disabled
        } else if compactComments {
            return .trailing
        } else {
            return .bottom
        }
    }
    
    var spacing: CGFloat { compactComments ? AppConstants.compactSpacing : AppConstants.postAndCommentSpacing }
    
    init(commentView: CommentModel,
         isCollapsed: Bool,
         showPostContext: Bool,
         menuFunctions: [MenuFunction]) {
        self.commentView = commentView
        self.isCollapsed = isCollapsed
        self.showPostContext = showPostContext
        self.menuFunctions = menuFunctions
        
        let commentor = commentView.creator
        let publishedAgo: String = getTimeIntervalFromNow(date: commentView.comment.published)
        commentorLabel = "Last updated \(publishedAgo) ago by \(commentor.displayName ?? commentor.name)"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            HStack(spacing: AppConstants.compactSpacing) {
                UserProfileLink(
                    user: commentView.creator,
                    serverInstanceLocation: serverInstanceLocation,
                    postContext: commentView.post,
                    commentContext: commentView.comment
                )
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(commentorLabel)
                .foregroundColor(.secondary)
                
                Spacer()
                
                if compactComments {
                    compactScoreDisplay()
                }
                
                EllipsisMenu(size: compactComments ? 20 : 24, menuFunctions: menuFunctions)
            }
            
            // comment text or placeholder
            Group {
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
    
    @ViewBuilder
    func compactScoreDisplay() -> some View {
        Group {
            // time
            TimestampView(date: commentView.published)
            
            // votes
            if showCommentDownvotesSeparately {
                HStack(spacing: AppConstants.iconToTextSpacing) {
                    Image(systemName: myVote == .upvote ? AppConstants.fullUpvoteSymbolName : AppConstants.emptyUpvoteSymbolName)
                    Text(String(commentView.votes.upvotes))
                }
                
                HStack(spacing: AppConstants.iconToTextSpacing) {
                    Image(systemName: myVote == .downvote ? AppConstants.fullDownvoteSymbolName : AppConstants.emptyDownvoteSymbolName)
                    Text(String(commentView.votes.downvotes))
                }
            } else {
                HStack(spacing: AppConstants.iconToTextSpacing) {
                    Image(systemName: AppConstants.scoringOpToVoteImage[myVote]!)
                    Text(String(commentView.votes.total))
                }
                .foregroundColor(.secondary)
                .font(.footnote)
            }
            
        }
        .foregroundColor(.secondary)
        .font(.footnote)
    }
}
