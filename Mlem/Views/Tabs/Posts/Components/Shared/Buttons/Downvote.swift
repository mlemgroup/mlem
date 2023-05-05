//
//  downvote.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import SwiftUI

struct DownvoteButton: View
{
    var body: some View
    {
        Button(action: {
            print("Downvoted")
        }, label: {
            Image(systemName: "arrow.down")
        })
    }
}

