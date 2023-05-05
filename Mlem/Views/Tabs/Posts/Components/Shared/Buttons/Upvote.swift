//
//  Upvote.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import SwiftUI

struct UpvoteButton: View
{
    @State var score: Int

    var body: some View
    {
        HStack(spacing: 2)
        {
            Button(action: {
                print("Upvoted")
            }, label: {
                Image(systemName: "arrow.up")
            })

            Text(String(score))
                .foregroundColor(.accentColor)
        }
    }
}
