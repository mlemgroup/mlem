//
//  Upvote Score Complex.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-13.
//

import Foundation
import SwiftUI

struct VoteComplex: View {
    let style: VoteComplexStyle
    let vote: ScoringOperation
    let score: Int
    let upvote: () async -> Void
    let downvote: () async -> Void

    var body: some View {
        Group {
            switch style {
            case .standard:
                StandardVoteComplex(vote: vote, score: score, upvote: upvote, downvote: downvote)
            case .symmetric:
                SymmetricVoteComplex(vote: vote, score: score, upvote: upvote, downvote: downvote)
            case .plain:
                PlainVoteComplex(vote: vote, score: score, upvote: upvote, downvote: downvote)
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
