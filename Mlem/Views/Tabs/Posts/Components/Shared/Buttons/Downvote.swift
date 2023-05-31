//
//  downvote.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import SwiftUI

struct DownvoteButton: View
{
    @Binding var score: Int
    
    var body: some View
    {
        
        Label("", systemImage: "arrow.down")
            .foregroundColor(.accentColor)
    }
}

