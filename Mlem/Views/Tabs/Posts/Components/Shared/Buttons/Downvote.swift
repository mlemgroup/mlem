//
//  downvote.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import SwiftUI

struct DownvoteButton: View {
    var myVote: MyVote

    var body: some View {
        Image(systemName: "arrow.down")
            .if (myVote == .downvoted) { viewProxy in
                viewProxy
                    .padding(4)
                    .foregroundColor(.white)
                    .background(RoundedRectangle(cornerRadius: 2)
                        .aspectRatio(1, contentMode: .fit)
                        .foregroundColor(.downvoteColor))
            }
            .if (myVote == .upvoted || myVote == .none) { viewProxy in
                viewProxy
                    .padding(4)
                    .foregroundColor(.primary)
            }
    }
}

