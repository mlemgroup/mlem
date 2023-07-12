//
//  Upvote.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import SwiftUI

struct UpvoteButtonLabel: View {
    let vote: ScoringOperation

    var body: some View {
        Image(systemName: "arrow.up")
            .resizable()
            .scaledToFit()
            .frame(width: AppConstants.barIconSize, height: AppConstants.barIconSize)
            .padding(AppConstants.barIconPadding)
            .foregroundColor(vote == .upvote ? .white : .primary)
            .background(RoundedRectangle(cornerRadius: AppConstants.smallItemCornerRadius)
                .aspectRatio(1, contentMode: .fit)
                .foregroundColor(vote == .upvote ? .upvoteColor : .clear))
            .padding(AppConstants.postAndCommentSpacing)
            .contentShape(Rectangle())
    }
}
