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

struct InfoStack: View {
  
    let votes: DetailedVotes?
    let published: Date?
    let commentCount: Int?
    let saved: Bool?
    
    var body: some View {
        HStack(spacing: 12) {
            if let votes {
                if votes.showDownvotes {
                    HStack(spacing: AppConstants.iconToTextSpacing) {
                        Image(systemName: votes.myVote == .upvote ? AppConstants.fullUpvoteSymbolName : AppConstants.emptyUpvoteSymbolName)
                        Text(String(votes.upvotes))
                    }
                    
                    HStack(spacing: AppConstants.iconToTextSpacing) {
                        Image(systemName: votes.myVote == .downvote
                              ? AppConstants.fullDownvoteSymbolName
                              : AppConstants.emptyDownvoteSymbolName)
                        Text(String(votes.downvotes))
                    }
                } else {
                    HStack(spacing: AppConstants.iconToTextSpacing) {
                        Image(systemName: AppConstants.scoringOpToVoteImage[votes.myVote]!)
                        Text(String(votes.score))
                    }
                }
            }
            
            if let published = published {
                TimestampView(date: published, spacing: AppConstants.iconToTextSpacing)
            }
            
            if let saved = saved {
                Image(systemName: saved ? AppConstants.fullSaveSymbolName : AppConstants.emptySaveSymbolName)
            }
            
            if let commentCount = commentCount {
                HStack(spacing: AppConstants.iconToTextSpacing) {
                    Image(systemName: "bubble.right")
                    Text(commentCount.description)
                }
            }
        }
        .foregroundColor(.secondary)
        .font(.footnote)
    }
}
