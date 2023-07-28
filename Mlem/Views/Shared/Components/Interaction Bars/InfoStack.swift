//
//  InfoStack.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-07.
//

import Foundation
import SwiftUI

struct InfoStack: View {    
    let score: Int?
    let upvotes: Int?
    let downvotes: Int?
    let myVote: ScoringOperation?
    let published: Date?
    let commentCount: Int?
    let saved: Bool?
    
    var body: some View {
        HStack(spacing: 12) {
            if let myVote = myVote {
                if let score = score {
                    HStack(spacing: AppConstants.iconToTextSpacing) {
                        Image(systemName: AppConstants.scoringOpToVoteImage[myVote]!)
                        Text(String(score))
                    }
                } else if let upvotes = upvotes, let downvotes = downvotes {
                    HStack(spacing: AppConstants.iconToTextSpacing) {
                        Image(systemName: myVote == .upvote ? AppConstants.fullUpvoteSymbolName : AppConstants.emptyUpvoteSymbolName)
                        Text(String(upvotes))
                    }
                    
                    HStack(spacing: AppConstants.iconToTextSpacing) {
                        Image(systemName: myVote == .downvote
                              ? AppConstants.fullDownvoteSymbolName
                              : AppConstants.emptyDownvoteSymbolName)
                        Text(String(downvotes))
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
