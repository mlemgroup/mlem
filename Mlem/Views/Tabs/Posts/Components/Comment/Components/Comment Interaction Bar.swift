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
    // environment
    @EnvironmentObject var commentTracker: CommentTracker
    
    // constants
    let iconToTextSpacing: CGFloat = 2
    let iconPadding: CGFloat = 4
    let iconCorner: CGFloat = 2
    let scoreItemWidth: CGFloat = 12
    
    // parameters
    let commentView: APICommentView
    let account: SavedAccount
    
    let displayedScore: Int
    let displayedVote: ScoringOperation
    let displayedSaved: Bool
    
    // let voteOnPost: (ScoringOperation) -> Void
    let upvote: () async -> Void
    let downvote: () async -> Void
    let saveComment: () async -> Void
    let deleteComment: () async -> Void
    
    // computed
    var publishedAgo: String { getTimeIntervalFromNow(date: commentView.post.published )}
    let height: CGFloat = 20
    
    var body: some View {
        HStack(spacing: 18) {
            VoteComplex(vote: displayedVote, score: displayedScore, height: height, upvote: upvote, downvote: downvote)
                .padding(.trailing, 8)
            
            SaveButton(isSaved: displayedSaved, size: height, accessibilityContext: "comment") {
                Task(priority: .userInitiated) {
                    await saveComment()
                }
            }
            
            
             if let postURL = URL(string: commentView.post.apId) {
                 ShareButton(size: height, accessibilityContext: "comment") {
                     showShareSheet(URLtoShare: postURL)
                 }
             }
            
            #warning("ERIC TODO: flesh out")
            EllipsisMenu(size: height, shareUrl: commentView.post.apId, deleteButtonCallback: canDeleteComment() ? self.deleteComment : nil)
            
            Spacer()
        }
        .font(.footnote)
    }
    
    func canDeleteComment() -> Bool {
        if commentView.creator.id != account.id {
            return false
        }
        
        if commentView.comment.deleted {
            return false
        }
        
        return true
    }
}

