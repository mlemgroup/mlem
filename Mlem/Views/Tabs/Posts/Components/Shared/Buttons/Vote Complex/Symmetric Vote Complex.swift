//
//  Symmetric Vote Complex.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-13.
//

import Foundation
import SwiftUI

struct SymmetricVoteComplex: View {
    @AppStorage("voteComplexOnRight") var shouldShowVoteComplexOnRight: Bool = false
    
    @EnvironmentObject var appState: AppState
    
    let vote: ScoringOperation
    let score: Int
    let upvote: () async -> Void
    let downvote: () async -> Void

    var scoreColor: Color {
        switch vote {
        case .upvote:
                return Color.upvoteColor
        case .resetVote:
                return Color.primary
        case .downvote:
                return Color.downvoteColor
        }
    }

    var body: some View {
        HStack(spacing: 6) {
            Button {
                Task(priority: .userInitiated) {
                    await upvote()
                }
            } label: {
                UpvoteButtonLabel(vote: vote)
            }
            // squish it towards the score
            .offset(x: AppConstants.postAndCommentSpacing)
            
            Text(String(score))
                .foregroundColor(scoreColor)
            
            if appState.enableDownvote {
                Button {
                    Task(priority: .userInitiated) {
                        await upvote()
                    }
                } label: {
                    DownvoteButtonLabel(vote: vote)
                        .onTapGesture {
                            Task(priority: .userInitiated) {
                                await downvote()
                            }
                        }
                }
                // squish it towards the score
                .offset(x: -AppConstants.postAndCommentSpacing)
            }
        }
        // undo score squishing weirdness
        .offset(x: (shouldShowVoteComplexOnRight ? 1 : -1) * (AppConstants.postAndCommentSpacing + 6))
    }
}
