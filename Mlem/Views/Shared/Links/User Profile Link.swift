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

    // Extra context about where the link is being displayed
    // to pick the correct flair
    var postContext: APIPost?
    var commentContext: APIComment?
    var showAvatar: Bool

    var body: some View {
        NavigationLink(value: user) {
            UserProfileLabel(
                user: user,
                serverInstanceLocation: serverInstanceLocation,
                showAvatar: showAvatar,
                postContext: postContext,
                commentContext: commentContext)
        }
    }
}
