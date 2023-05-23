//
//  Post Upvote Button.swift
//  Mlem
//
//  Created by David Bureš on 23.05.2023.
//

import SwiftUI

struct PostUpvoteButton: View
{
    @State var post: Post

    var body: some View
    {
        HStack(alignment: .center, spacing: 2)
        {
            Image(systemName: "arrow.up")

            Text(String(post.score))
        }
        .if(post.myVote == .none)
        { viewProxy in
            viewProxy
                .foregroundColor(.accentColor)
        }
        .if(post.myVote == .upvoted)
        { viewProxy in
            viewProxy
                .foregroundColor(.green)
        }
    }
}
