//
//  downvote.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import SwiftUI

struct DownvoteButton: View {
    let vote: ScoringOperation

    var body: some View {
        Image(systemName: "arrow.down")
            .padding(4)
            .foregroundColor(vote == .downvote ? .white : .primary)
            .background(RoundedRectangle(cornerRadius: 2)
                .aspectRatio(1, contentMode: .fit)
                .foregroundColor(vote == .downvote ? .downvoteColor : .white))
    }
}

