//
//  InfoStack.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-07.
//

import Foundation
import SwiftUI

// this simplifies the two-phase logic of "show votes at all? -> show downvotes separately?"--can be passed in as an optional for the first, and contains the toggle for the second. Can't just grab settings value for the second because InfoStack is used in both posts and comments.
struct DetailedVotes {
    let score: Int
    let upvotes: Int
    let downvotes: Int
    let showDownvotes: Bool
}

struct InfoStack: View {
  
    let votes: DetailedVotes?
    let myVote: ScoringOperation?
    let published: Date?
    let commentCount: Int?
    let saved: Bool?
    
    var body: some View {
        HStack(spacing: 12) {
            if let myVote = myVote, let votes {
                if votes.showDownvotes {
                    HStack(spacing: AppConstants.iconToTextSpacing) {
                        Image(systemName: myVote == .upvote ? AppConstants.fullUpvoteSymbolName : AppConstants.emptyUpvoteSymbolName)
                        Text(String(votes.upvotes))
                    }
                    
                    HStack(spacing: AppConstants.iconToTextSpacing) {
                        Image(systemName: myVote == .downvote
                              ? AppConstants.fullDownvoteSymbolName
                              : AppConstants.emptyDownvoteSymbolName)
                        Text(String(votes.downvotes))
                    }
                } else {
                    HStack(spacing: AppConstants.iconToTextSpacing) {
                        Image(systemName: AppConstants.scoringOpToVoteImage[myVote]!)
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
