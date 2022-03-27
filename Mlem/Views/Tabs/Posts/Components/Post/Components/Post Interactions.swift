//
//  Post Interactions.swift
//  Mlem
//
//  Created by David Bureš on 27.03.2022.
//

import SwiftUI

struct Post_Interactions: View {
    var body: some View {
        HStack(alignment: .center) {
            Upvote_Button()
            Downvote_Button()
            Share_Button()
        }
    }
}

struct Post_Interactions_Previews: PreviewProvider {
    static var previews: some View {
        Post_Interactions()
    }
}
