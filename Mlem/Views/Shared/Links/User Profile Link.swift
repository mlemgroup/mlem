//
//  User Profile Link.swift
//  Mlem
//
//  Created by David Bureš on 02.04.2022.
//

import SwiftUI

struct UserProfileLink: View {
    var user: APIPerson
    let serverInstanceLocation: ServerInstanceLocation
    var overrideShowAvatar: Bool? // shows or hides the avatar according to value. If not set, uses system setting.

    // Extra context about where the link is being displayed
    // to pick the correct flair
    var postContext: APIPost?
    var commentContext: APIComment?
    
    init(
        user: APIPerson,
        serverInstanceLocation: ServerInstanceLocation,
        overrideShowAvatar: Bool? = nil,
        postContext: APIPost? = nil,
        commentContext: APIComment? = nil
    ) {
        self.user = user
        self.serverInstanceLocation = serverInstanceLocation
        self.overrideShowAvatar = overrideShowAvatar
        self.postContext = postContext
        self.commentContext = commentContext
    }

    var body: some View {
        NavigationLink(value: user) {
            UserProfileLabel(
                user: user,
                serverInstanceLocation: serverInstanceLocation,
                overrideShowAvatar: overrideShowAvatar,
                postContext: postContext,
                commentContext: commentContext
            )
        }
    }
}
