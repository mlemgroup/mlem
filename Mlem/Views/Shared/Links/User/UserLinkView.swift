//
//  User Profile Link.swift
//  Mlem
//
//  Created by David Bureš on 02.04.2022.
//

import SwiftUI

struct UserLinkView: View {
    var user: UserModel
    let serverInstanceLocation: ServerInstanceLocation
    var overrideShowAvatar: Bool? // shows or hides the avatar according to value. If not set, uses system setting.

    // Extra context about where the link is being displayed
    // to pick the correct flair
    var postContext: APIPost?
    var commentContext: APIComment?
    var communityContext: CommunityModel?
    
    @available(*, deprecated, message: "Provide a UserModel rather than an APIPerson.")
    init(
        person: APIPerson,
        serverInstanceLocation: ServerInstanceLocation,
        overrideShowAvatar: Bool? = nil,
        postContext: APIPost? = nil,
        commentContext: APIComment? = nil,
        communityContext: CommunityModel? = nil
    ) {
        self.init(
            user: UserModel(from: person),
            serverInstanceLocation: serverInstanceLocation,
            overrideShowAvatar: overrideShowAvatar,
            postContext: postContext,
            commentContext: commentContext,
            communityContext: communityContext
        )
    }
    
    init(
        user: UserModel,
        serverInstanceLocation: ServerInstanceLocation,
        overrideShowAvatar: Bool? = nil,
        postContext: APIPost? = nil,
        commentContext: APIComment? = nil,
        communityContext: CommunityModel? = nil

    ) {
        self.user = user
        self.serverInstanceLocation = serverInstanceLocation
        self.overrideShowAvatar = overrideShowAvatar
        self.postContext = postContext
        self.commentContext = commentContext
        self.communityContext = communityContext
        print(communityContext?.moderators)
    }

    var body: some View {
        NavigationLink(.userProfile(user, communityContext: communityContext)) {
            UserLabelView(
                user: user,
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
