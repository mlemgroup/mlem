//
//  InfoStack.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-07.
//

import Foundation
import SwiftUI

struct InfoStack: View {
    let score: Int
    let published: Date
    let commentCount: Int
    let myVote: ScoringOperation
    
    var body: some View {
        HStack(spacing: 12) {
            HStack(spacing: AppConstants.iconToTextSpacing) {
                Image(systemName: AppConstants.scoringOpToVoteImage[myVote]!)
                Text(String(score))
            }
            
            TimestampView(date: published, spacing: AppConstants.iconToTextSpacing)
            
            HStack(spacing: AppConstants.iconToTextSpacing) {
                Image(systemName: "bubble.right")
                Text(commentCount.description)
            }
        }
        .foregroundColor(.secondary)
        .font(.footnote)
    }
}
