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
    
    let commentModel: CommentModel
    let isCollapsed: Bool
    let showPostContext: Bool
    let commentorLabel: String
    let menuFunctions: [MenuFunction]
    
    var myVote: ScoringOperation { commentModel.votes.myVote }
    
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
        self.commentModel = commentView
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
                    user: commentModel.creator,
                    serverInstanceLocation: serverInstanceLocation,
                    postContext: commentModel.post,
                    commentContext: commentModel.comment
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
                if commentModel.deleted {
                    Text("Comment was deleted")
                        .italic()
                        .foregroundColor(.secondary)
                } else if commentModel.comment.removed {
                    Text("Comment was removed")
                        .italic()
                        .foregroundColor(.secondary)
                } else if !isCollapsed {
                    MarkdownView(text: commentModel.comment.content, isNsfw: commentModel.post.nsfw)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                }
            }
            
            // embedded post
            if showPostContext {
                EmbeddedPost(
                    community: commentModel.community,
                    post: commentModel.post
                )
            }
        }
    }
    
    @ViewBuilder
    func compactScoreDisplay() -> some View {
        Group {
            // time
            TimestampView(date: commentModel.published)
            
            // votes
            if showCommentDownvotesSeparately {
                HStack(spacing: AppConstants.iconToTextSpacing) {
                    Image(systemName: myVote == .upvote ? AppConstants.fullUpvoteSymbolName : AppConstants.emptyUpvoteSymbolName)
                    Text(String(commentModel.votes.upvotes))
                }
                
                HStack(spacing: AppConstants.iconToTextSpacing) {
                    Image(systemName: myVote == .downvote ? AppConstants.fullDownvoteSymbolName : AppConstants.emptyDownvoteSymbolName)
                    Text(String(commentModel.votes.downvotes))
                }
            } else {
                HStack(spacing: AppConstants.iconToTextSpacing) {
                    Image(systemName: AppConstants.scoringOpToVoteImage[myVote]!)
                    Text(String(commentModel.votes.total))
                }
                .foregroundColor(.secondary)
                .font(.footnote)
            }
            
        }
        .foregroundColor(.secondary)
        .font(.footnote)
    }
}
