//
//  Post Downvote Button.swift
//  Mlem
//
//  Created by David Bureš on 23.05.2023.
//

import SwiftUI

struct PostDownvoteButton: View
{
    var post: Post

    var body: some View
    {
        Image(systemName: "arrow.down")
            .foregroundColor(.accentColor)
            .if(post.myVote == .downvoted)
            { viewProxy in
                viewProxy
                    .foregroundColor(.red)
            }
    }
}
