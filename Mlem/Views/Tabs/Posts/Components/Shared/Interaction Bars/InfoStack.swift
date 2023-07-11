//
//  InfoStack.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-07.
//

import Foundation
import SwiftUI

struct InfoStack: View {
    @AppStorage("shouldShowUpvotesInBar") var shouldShowUpvotesInBar: Bool = false
    @AppStorage("shouldShowTimeInBar") var shouldShowTimeInBar: Bool = true
    @AppStorage("shouldShowSavedInBar") var shouldShowSavedInBar: Bool = false
    @AppStorage("shouldShowRepliesInBar") var shouldShowRepliesInBar: Bool = true
    
    let score: Int
    let published: Date
    let commentCount: Int
    let myVote: ScoringOperation
    let saved: Bool
    let compactMode: Bool
    
    init(score: Int,
         published: Date,
         commentCount: Int,
         myVote: ScoringOperation,
         saved: Bool,
         compactMode: Bool = false) {
        self.score = score
        self.published = published
        self.commentCount = commentCount
        self.myVote = myVote
        self.saved = saved
        self.compactMode = compactMode
    }
    
    var body: some View {
        HStack(spacing: 12) {
            if compactMode || shouldShowUpvotesInBar {
                HStack(spacing: AppConstants.iconToTextSpacing) {
                    Image(systemName: AppConstants.scoringOpToVoteImage[myVote]!)
                    Text(String(score))
                }
            }
            
            if compactMode || shouldShowTimeInBar {
                TimestampView(date: published, spacing: AppConstants.iconToTextSpacing)
            }
            
            if compactMode || shouldShowSavedInBar {
                Image(systemName: saved ? AppConstants.fullSaveSymbolName : AppConstants.emptySaveSymbolName)
            }
            
            if compactMode || shouldShowRepliesInBar {
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
