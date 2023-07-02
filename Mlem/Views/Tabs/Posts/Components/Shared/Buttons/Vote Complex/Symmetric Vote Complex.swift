//
//  Symmetric Vote Complex.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-13.
//

import Foundation
import SwiftUI

struct SymmetricVoteComplex: View {
    
    @EnvironmentObject var appState: AppState
    
    let vote: ScoringOperation
    let score: Int
    let height: CGFloat
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
            UpvoteButton(vote: vote, size: height)
                .onTapGesture {
                    Task(priority: .userInitiated) {
                        await upvote()
                    }
                }
            Text(String(score))
                .foregroundColor(scoreColor)
            if appState.enableDownvote {
                DownvoteButton(vote: vote, size: height)
                    .onTapGesture {
                        Task(priority: .userInitiated) {
                            await downvote()
                        }
                    }
            }
        }
        .frame(height: height)
    }
}
