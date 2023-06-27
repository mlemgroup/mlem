//
//  Upvote.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import SwiftUI

struct UpvoteButton: View {
    let vote: ScoringOperation
    let size: CGFloat

    var body: some View {
        Image(systemName: "arrow.up")
            // .padding(4)
            .frame(width: size, height: size)
            .foregroundColor(vote == .upvote ? .white : .primary)
            .background(RoundedRectangle(cornerRadius: 4)
                .aspectRatio(1, contentMode: .fit)
                .foregroundColor(vote == .upvote ? .upvoteColor : .clear))
    }
}
