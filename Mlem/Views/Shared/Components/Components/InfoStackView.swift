//
//  InfoStackView.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-07.
//

import Foundation
import SwiftUI

/// This struct addresses the two-phase logic of "show votes at all? -> show downvotes separately?" while maintaining the InfoStack approach of "take in optional parameters and render all the non-nil ones." The showDownvotes toggle needs to be passed in because it's maintained separately for posts and for comments, so InfoStack either needs to know whether it's a post or a comment or it just needs to be told which way to display, the latter of which options seems much nicer given that this is a very "dumb" struct
struct DetailedVotes {
    let score: Int
    let upvotes: Int
    let downvotes: Int
    let myVote: ScoringOperation
    let showDownvotes: Bool
}

struct InfoStackView: View {
    let votes: DetailedVotes?
    let published: Date?
    let updated: Date?
    let commentCount: Int?
    let unreadCommentCount: Int?
    
    let saved: Bool?
    let alignment: HorizontalAlignment
    let colorizeVotes: Bool
    
    var body: some View {
        HStack {
            if alignment == .trailing {
                Spacer()
            }
            HStack(spacing: 12) {
                if let votes {
                    if votes.showDownvotes {
                        upvotesView(votes: votes)
                        downvotesView(votes: votes)
                    } else {
                        netVotesView(votes: votes)
                    }
                }
                
                if let updated {
                    UpdatedTimestampView(date: updated, spacing: AppConstants.iconToTextSpacing)
                } else if let published {
                    PublishedTimestampView(date: published, spacing: AppConstants.iconToTextSpacing)
                }
                
                if let saved {
                    savedView(isSaved: saved)
                }
                
                if let commentCount {
                    if let unreadCommentCount, unreadCommentCount > 0, unreadCommentCount != commentCount {
                        unreadRepliesView(commentCount: commentCount, unreadCommentCount: unreadCommentCount)
                    } else {
                        repliesView(commentCount: commentCount)
                    }
                }
            }
            .fixedSize()
            if alignment == .leading {
                Spacer()
            }
        }
        .frame(height: AppConstants.barIconSize)
        .foregroundColor(.secondary)
        .font(.footnote)
        .monospacedDigit()
    }
    
    @ViewBuilder
    func netVotesView(votes: DetailedVotes) -> some View {
        HStack(spacing: AppConstants.iconToTextSpacing) {
            Image(systemName: votes.myVote == .none ? Icons.upvoteSquare : votes.myVote.iconNameFill)
            Text(String(votes.score))
        }
        .foregroundColor(colorizeVotes ? votes.myVote.color ?? .secondary : .secondary)
        .accessibilityAddTraits(.isStaticText)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(votes.score) net votes")
    }
    
    @ViewBuilder
    func upvotesView(votes: DetailedVotes) -> some View {
        HStack(spacing: AppConstants.iconToTextSpacing) {
            Image(systemName: votes.myVote == .upvote ? Icons.upvoteSquareFill : Icons.upvoteSquare)
            Text(String(votes.upvotes))
        }
        .foregroundColor(colorizeVotes && votes.myVote == .upvote ? .upvoteColor : .secondary)
        .accessibilityAddTraits(.isStaticText)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(votes.upvotes) upvotes")
    }
    
    @ViewBuilder
    func downvotesView(votes: DetailedVotes) -> some View {
        HStack(spacing: AppConstants.iconToTextSpacing) {
            Image(systemName: votes.myVote == .downvote
                ? Icons.downvoteSquareFill
                : Icons.downvoteSquare)
            Text(String(votes.downvotes))
        }
        .foregroundColor(colorizeVotes && votes.myVote == .downvote ? .downvoteColor : .secondary)
        .accessibilityAddTraits(.isStaticText)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(votes.downvotes) downvotes")
    }
    
    @ViewBuilder
    func savedView(isSaved: Bool) -> some View {
        Image(systemName: isSaved ? Icons.saveFill : Icons.save)
            .accessibilityAddTraits(.isStaticText)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(isSaved ? "saved" : "")
    }
    
    @ViewBuilder
    func repliesView(commentCount: Int) -> some View {
        HStack(spacing: AppConstants.iconToTextSpacing) {
            Image(systemName: Icons.replies)
            Text(String(describing: commentCount))
        }
        .accessibilityAddTraits(.isStaticText)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(commentCount) comments")
    }
    
    @ViewBuilder
    func unreadRepliesView(commentCount: Int, unreadCommentCount: Int) -> some View {
        HStack(spacing: AppConstants.iconToTextSpacing) {
            Image(systemName: Icons.unreadReplies)
            Text("\(commentCount)")
                + Text(" +\(unreadCommentCount)").foregroundColor(.green)
        }
        .accessibilityAddTraits(.isStaticText)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(commentCount) comments, \(unreadCommentCount) new")
    }
}
