//
//  Post Downvote Button.swift
//  Mlem
//
//  Created by David Bureš on 23.05.2023.
//

import SwiftUI

struct PostDownvoteButton: View
{
    @State var post: Post

    var body: some View
    {
        Image(systemName: "arrow.down")
            .if(post.myVote == .none)
            { viewProxy in
                viewProxy
                    .foregroundColor(.accentColor)
            }
            .if(post.myVote == .none)
            { viewProxy in
                viewProxy
                    .foregroundColor(.accentColor)
            }
            .if(post.myVote == .downvoted)
            { viewProxy in
                viewProxy
                    .foregroundColor(.red)
            }
    }
}
