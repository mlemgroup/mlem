//
//  Standard Vote Complex.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-13.
//

import Foundation
import SwiftUI

struct UpvoteCounterView: View {
    
    @EnvironmentObject var appState: AppState
    
    // parameters
    let vote: ScoringOperation
    let score: Int
    let upvote: () async -> Void

    var body: some View {
        HStack(spacing: 0) {
            Button {
                Task(priority: .userInitiated) {
                    await upvote()
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.up")
                    Text(String(score))
                        .monospacedDigit()
                }
                // custom set because grouping image and text makes height do bad things
                .frame(height: AppConstants.barIconSize + 2 * AppConstants.barIconPadding)
                .padding(.horizontal, 4) // for the background to look right
                .background(RoundedRectangle(cornerRadius: AppConstants.tinyItemCornerRadius)
                    .foregroundColor(vote == .upvote ? .upvoteColor : .clear))
                .foregroundColor(vote == .upvote ? .white : .primary)
                // .padding(.leading, AppConstants.postAndCommentSpacing - 4) // offset, undo background padding
                .padding(AppConstants.postAndCommentSpacing)
            }
        }
    }
}
