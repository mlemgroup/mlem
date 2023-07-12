//
//  Plain Vote Compoex.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-10.
//

import Foundation
import SwiftUI

struct PlainVoteComplex: View {
    
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
        HStack(spacing: 0) {
            Button {
                Task(priority: .userInitiated) {
                    await upvote()
                }
            } label: {
                UpvoteButtonLabel(vote: vote)
            }
            
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
            }
        }
    }
}
