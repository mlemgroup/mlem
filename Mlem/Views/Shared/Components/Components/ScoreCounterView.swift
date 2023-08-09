//
//  Symmetric Vote Complex.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-13.
//

import Foundation
import SwiftUI

struct ScoreCounterView: View {
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
            UpvoteButtonView(vote: vote, upvote: upvote)
            .offset(x: AppConstants.postAndCommentSpacing)
            
            Text(String(score))
                .foregroundColor(scoreColor)
            
            if appState.enableDownvote {
                DownvoteButtonView(vote: vote, downvote: downvote)
                .offset(x: -AppConstants.postAndCommentSpacing)
            }
        }
        .padding(.horizontal, -AppConstants.postAndCommentSpacing)
        .accessibilityElement(children: .ignore)
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment:
                Task(priority: .userInitiated) {
                    await upvote()
                }
            case .decrement:
                Task(priority: .userInitiated) {
                    await downvote()
                }
            default:
                // Not sure what to do here.
                UIAccessibility.post(notification: .announcement, argument: "Unknown Action")
            }
        }
        .monospacedDigit()
    }
}
