//
//  DownvoteButtonView.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import SwiftUI

struct DownvoteButtonView: View {
    let vote: ScoringOperation
    let downvote: () async -> Void

    var body: some View {
        Button {
            Task(priority: .userInitiated) {
                await downvote()
            }
        } label: {
            Image(systemName: Icons.downvote)
                .resizable()
                .scaledToFit()
                .frame(width: AppConstants.barIconSize, height: AppConstants.barIconSize)
                .padding(AppConstants.barIconPadding)
                .foregroundColor(vote == .downvote ? .white : .primary)
                .background(RoundedRectangle(cornerRadius: AppConstants.tinyItemCornerRadius)
                    .aspectRatio(1, contentMode: .fit)
                    .foregroundColor(vote == .downvote ? .downvoteColor : .clear))
                .padding(AppConstants.postAndCommentSpacing)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .transaction { transaction in
            transaction.disablesAnimations = true
        }
    }
}
