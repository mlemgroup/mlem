//
//  User Profile Link.swift
//  Mlem
//
//  Created by David Bureš on 02.04.2022.
//

import SwiftUI

struct PersonLinkView: View {
    var person: any Person
    let serverInstanceLocation: ServerInstanceLocation
    var overrideShowAvatar: Bool? // shows or hides the avatar according to value. If not set, uses system setting.

    // Extra context about where the link is being displayed
    // to pick the correct flair
    var postContext: (any Post)?
    var commentContext: APIComment?
    var communityContext: (any Community)?
    
    init(
        person: any Person,
        serverInstanceLocation: ServerInstanceLocation,
        overrideShowAvatar: Bool? = nil,
        postContext: (any Post)? = nil,
        commentContext: APIComment? = nil,
        communityContext: (any Community)? = nil

    ) {
        self.person = person
        self.serverInstanceLocation = serverInstanceLocation
        self.overrideShowAvatar = overrideShowAvatar
        self.postContext = postContext
        self.commentContext = commentContext
        self.communityContext = communityContext
    }

    var body: some View {
        NavigationLink(.person(person, communityContext: communityContext)) {
            PersonLabelView(
                person: person,
                serverInstanceLocation: serverInstanceLocation,
                overrideShowAvatar: overrideShowAvatar,
                postContext: postContext,
                commentContext: commentContext,
                communityContext: communityContext
            )
        }
        .buttonStyle(.plain)
    }
}
