//
//  Upvote.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import SwiftUI

struct UpvoteButtonView: View {
    let vote: ScoringOperation
    let upvote: () async -> Void

    var body: some View {
        Button {
            Task(priority: .userInitiated) {
                await upvote()
            }
        } label: {
            Image(systemName: "arrow.up")
                .resizable()
                .scaledToFit()
                .frame(width: AppConstants.barIconSize, height: AppConstants.barIconSize)
                .padding(AppConstants.barIconPadding)
                .foregroundColor(vote == .upvote ? .white : .primary)
                .background(RoundedRectangle(cornerRadius: AppConstants.tinyItemCornerRadius)
                    .aspectRatio(1, contentMode: .fit)
                    .foregroundColor(vote == .upvote ? .upvoteColor : .clear))
                .padding(AppConstants.postAndCommentSpacing)
                .contentShape(Rectangle())
        }
    }
}
