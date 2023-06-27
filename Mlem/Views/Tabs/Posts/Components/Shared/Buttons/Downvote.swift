//
//  downvote.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import SwiftUI

struct DownvoteButton: View {
    let vote: ScoringOperation
    let size: CGFloat

    var body: some View {
        Image(systemName: "arrow.down")
            .frame(width: size, height: size)
            .foregroundColor(vote == .downvote ? .white : .primary)
            .background(RoundedRectangle(cornerRadius: 4)
                .aspectRatio(1, contentMode: .fit)
                .foregroundColor(vote == .downvote ? .downvoteColor : .clear))

    }
}
