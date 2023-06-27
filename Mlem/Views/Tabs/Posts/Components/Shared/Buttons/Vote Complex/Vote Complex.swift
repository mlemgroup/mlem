//
//  Upvote Score Complex.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-13.
//

import Foundation
import SwiftUI

struct VoteComplex: View {
    // whether to display default or symmetric score
    @AppStorage("voteComplexStyle") var voteComplexStyle: VoteComplexStyle = .standard
    @AppStorage("shouldShowCompactPosts") var compact: Bool = false

    let vote: ScoringOperation
    let score: Int
    let height: CGFloat
    let upvote: () async -> Void
    let downvote: () async -> Void

    var body: some View {
        Group {
            switch voteComplexStyle {
            case .standard:
                StandardVoteComplex(vote: vote, score: score, height: height, upvote: upvote, downvote: downvote)
            case .symmetric:
                SymmetricVoteComplex(vote: vote, score: score, height: height, upvote: upvote, downvote: downvote)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityValue("\(score) votes")
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
    }
}
