//
//  Post Interactions.swift
//  Mlem
//
//  Created by David Bureš on 27.03.2022.
//

import SwiftUI

struct Post_Interactions: View
{
    let score: Int

    let urlToPost: String

    var body: some View
    {
        HStack(alignment: .center)
        {
            Upvote_Button(score: score)
            Downvote_Button()
            Share_Button(urlToShare: urlToPost)
        }
    }
}
