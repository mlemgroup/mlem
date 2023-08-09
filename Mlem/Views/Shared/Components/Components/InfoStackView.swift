//
//  InfoStack.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-07.
//

import Foundation
import SwiftUI

/**
 This struct addresses the two-phase logic of "show votes at all? -> show downvotes separately?" while maintaining the InfoStack approach of "take in optional parameters and render all the non-nil ones." The showDownvotes toggle needs to be passed in because it's maintained separately for posts and for comments, so InfoStack either needs to know whether it's a post or a comment or it just needs to be told which way to display, the latter of which options seems much nicer given that this is a very "dumb" struct
 */
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
    let commentCount: Int?
    let saved: Bool?
    let alignment: HorizontalAlignment
    
    var body: some View {
        HStack(spacing: 12) {
            if alignment == .trailing {
                Spacer()
            }
            if let votes {
                if votes.showDownvotes {
                    upvotesView(votes: votes)
                    downvotesView(votes: votes)
                } else {
                    netVotesView(votes: votes)
                }
            }
            
            if let published {
                TimestampView(date: published, spacing: AppConstants.iconToTextSpacing)
            }
            
            if let saved {
                savedView(isSaved: saved)
            }
            
            if let commentCount {
                repliesView(numReplies: commentCount)
            }
            if alignment == .leading {
                Spacer()
            }
        }
        .frame(height: AppConstants.barIconSize)
        .foregroundColor(.secondary)
        .font(.footnote)
    }
    
    @ViewBuilder
    func netVotesView(votes: DetailedVotes) -> some View {
        HStack(spacing: AppConstants.iconToTextSpacing) {
            Image(systemName: AppConstants.scoringOpToVoteImage[votes.myVote]!)
            Text(String(votes.score))
        }
        .accessibilityAddTraits(.isStaticText)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(votes.score) net votes")
    }
    
    @ViewBuilder
    func upvotesView(votes: DetailedVotes) -> some View {
        HStack(spacing: AppConstants.iconToTextSpacing) {
            Image(systemName: votes.myVote == .upvote ? AppConstants.fullUpvoteSymbolName : AppConstants.emptyUpvoteSymbolName)
            Text(String(votes.upvotes))
        }
        .accessibilityAddTraits(.isStaticText)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(votes.upvotes) upvotes")
    }
    
    @ViewBuilder
    func downvotesView(votes: DetailedVotes) -> some View {
        HStack(spacing: AppConstants.iconToTextSpacing) {
            Image(systemName: votes.myVote == .downvote
                  ? AppConstants.fullDownvoteSymbolName
                  : AppConstants.emptyDownvoteSymbolName)
            Text(String(votes.downvotes))
        }
        .accessibilityAddTraits(.isStaticText)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(votes.downvotes) downvotes")
    }
    
    @ViewBuilder
    func savedView(isSaved: Bool) -> some View {
        Image(systemName: isSaved ? AppConstants.fullSaveSymbolName : AppConstants.emptySaveSymbolName)
            .accessibilityAddTraits(.isStaticText)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(isSaved ? "saved" : "")
    }
    
    @ViewBuilder
    func repliesView(numReplies: Int) -> some View {
        HStack(spacing: AppConstants.iconToTextSpacing) {
            Image(systemName: "bubble.right")
            Text(numReplies.description)
        }
        .accessibilityAddTraits(.isStaticText)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(numReplies) comments")
    }
}
