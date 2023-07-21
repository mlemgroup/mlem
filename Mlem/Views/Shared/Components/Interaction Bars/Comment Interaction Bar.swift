//
//  Comment Interaction Bar.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-10.
//

import SwiftUI

import Foundation

/**
 View grouping post interactions--upvote, downvote, save, reply, plus post info
 */
struct CommentInteractionBar: View {
    @AppStorage("voteComplexOnRight") var shouldShowVoteComplexOnRight: Bool = false
    @AppStorage("commentVoteComplexStyle") var commentVoteComplexStyle: VoteComplexStyle = .standard
    @AppStorage("shouldShowScoreInCommentBar") var shouldShowScoreInCommentBar: Bool = false
    @AppStorage("shouldShowTimeInCommentBar") var shouldShowTimeInCommentBar: Bool = true
    @AppStorage("shouldShowSavedInCommentBar") var shouldShowSavedInCommentBar: Bool = false
    @AppStorage("shouldShowRepliesInCommentBar") var shouldShowRepliesInCommentBar: Bool = true
    
    // environment
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var commentTracker: CommentTracker

    // constants
    let iconPadding: CGFloat = 4
    let iconCorner: CGFloat = 2
    let scoreItemWidth: CGFloat = 12

    // parameters
    let commentView: APICommentView

    let displayedScore: Int
    let displayedVote: ScoringOperation
    let displayedSaved: Bool
    
    let upvote: () async -> Void
    let downvote: () async -> Void
    let saveComment: () async -> Void
    let deleteComment: () async -> Void
    let replyToComment: () -> Void

    let height: CGFloat = 24

    var body: some View {
        ZStack {
            HStack(spacing: 12) {
                if !shouldShowVoteComplexOnRight {
                    VoteComplex(style: commentVoteComplexStyle,
                                vote: displayedVote,
                                score: displayedScore,
                                upvote: upvote,
                                downvote: downvote)
                        .padding(.trailing, 8)
                } else {
                    SaveButton(isSaved: displayedSaved, accessibilityContext: "comment") {
                        Task(priority: .userInitiated) {
                            await saveComment()
                        }
                    }

                    ReplyButton(replyCount: commentView.counts.childCount, accessibilityContext: "comment", reply: replyToComment)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                if shouldShowVoteComplexOnRight {
                    VoteComplex(style: commentVoteComplexStyle,
                                vote: displayedVote,
                                score: displayedScore,
                                upvote: upvote,
                                downvote: downvote)
                        .padding(.trailing, 8)
                } else {
                    SaveButton(isSaved: displayedSaved, accessibilityContext: "comment") {
                        Task(priority: .userInitiated) {
                            await saveComment()
                        }
                    }
                    
                    ReplyButton(replyCount: commentView.counts.childCount, accessibilityContext: "comment", reply: replyToComment)
                        .foregroundColor(.primary)
                }
            }
            
            InfoStack(score: shouldShowScoreInCommentBar ? displayedScore : nil,
                      myVote: shouldShowScoreInCommentBar ? displayedVote : nil,
                      published: shouldShowTimeInCommentBar ? commentView.comment.published : nil,
                      commentCount: shouldShowRepliesInCommentBar ? commentView.counts.childCount : nil,
                      saved: shouldShowSavedInCommentBar ? commentView.saved : nil)
        }
        .font(.callout)
    }
    
    func canDeleteComment() -> Bool {
        if commentView.creator.id != appState.currentActiveAccount.id {
            return false
        }
        
        if commentView.comment.deleted {
            return false
        }
        
        return true
    }
}
