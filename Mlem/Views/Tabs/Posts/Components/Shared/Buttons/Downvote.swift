//
//  downvote.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import SwiftUI

struct DownvoteButtonLabel: View {
    let vote: ScoringOperation

    var body: some View {
        Image(systemName: "arrow.down")
            .resizable()
            .scaledToFit()
            .frame(width: AppConstants.barIconSize, height: AppConstants.barIconSize)
            .padding(AppConstants.barIconPadding)
            .foregroundColor(vote == .downvote ? .white : .primary)
            .background(RoundedRectangle(cornerRadius: AppConstants.smallItemCornerRadius)
                .aspectRatio(1, contentMode: .fit)
                .foregroundColor(vote == .downvote ? .downvoteColor : .clear))
            .padding(AppConstants.postAndCommentSpacing)
            .contentShape(Rectangle())
    }
}
