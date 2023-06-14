//
//  Standard Vote Complex.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-13.
//

import Foundation
import SwiftUI

struct StandardVoteComplex: View {
    let vote: ScoringOperation
    let score: Int
    let upvote: () async -> Void
    let downvote: () async -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            HStack(spacing: 2) {
                Image(systemName: "arrow.up")
                Text(String(score))
            }
            .padding(4)
            .background(RoundedRectangle(cornerRadius: 4)
                .foregroundColor(vote == .upvote ? .upvoteColor : .clear))
            .foregroundColor(vote == .upvote ? .white : .primary)
            .onTapGesture {
                Task(priority: .userInitiated) {
                    await upvote()
                }
            }
            
            DownvoteButton(vote: vote)
                .onTapGesture {
                    Task(priority: .userInitiated) {
                        await downvote()
                    }
                }
        }
    }
}
