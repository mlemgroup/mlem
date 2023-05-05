//
//  Post Interactions.swift
//  Mlem
//
//  Created by David Bureš on 27.03.2022.
//

import SwiftUI

struct PostInteractions: View
{
    @State var score: Int

    @State var urlToPost: URL

    var body: some View
    {
        HStack(alignment: .center)
        {
            UpvoteButton(score: score)
            DownvoteButton()
            ShareButton(urlToShare: urlToPost)
        }
    }
}
