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
    
    let vote: ScoringOperation
    let score: Int
    let upvote: () async -> Void
    let downvote: () async -> Void
    
    var body: some View {
        switch voteComplexStyle {
        case .standard:
            StandardVoteComplex(vote: vote, score: score, upvote: upvote, downvote: downvote)
        case .symmetric:
            SymmetricVoteComplex(vote: vote, score: score, upvote: upvote, downvote: downvote)
        }
    }
}
