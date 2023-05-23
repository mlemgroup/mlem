//
//  Post Upvote Button.swift
//  Mlem
//
//  Created by David Bureš on 23.05.2023.
//

import SwiftUI

struct PostUpvoteButton: View
{
    let upvotes: Int
    let downvotes: Int
    
    let myVote: MyVote

    var body: some View
    {
        HStack(alignment: .center, spacing: 2)
        {
            Image(systemName: "arrow.up")

            Text(String(upvotes - downvotes))
        }
        .if(myVote == .none)
        { viewProxy in
            viewProxy
                .foregroundColor(.accentColor)
        }
        .if(myVote == .upvoted)
        { viewProxy in
            viewProxy
                .foregroundColor(.green)
        }
        .onChange(of: upvotes) { newValue in
            print("Detected change in upvotes: \(upvotes)")
        }
    }
}
