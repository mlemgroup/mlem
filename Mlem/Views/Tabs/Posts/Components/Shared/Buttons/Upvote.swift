//
//  Upvote.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import SwiftUI

struct UpvoteButton: View {
    var myVote: MyVote

    var body: some View {
        Image(systemName: "arrow.up")
            .if (myVote == .upvoted) { viewProxy in
                viewProxy
                    .padding(4)
                    .foregroundColor(.white)
                    .background(RoundedRectangle(cornerRadius: 2)
                        .aspectRatio(1, contentMode: .fit)
                        .foregroundColor(.upvoteColor))
            }
            .if (myVote == .none || myVote == .downvoted) { viewProxy in
                viewProxy
                    .padding(4)
                    .foregroundColor(.accentColor)
            }
    }
}

