//
//  User Profile Link.swift
//  Mlem
//
//  Created by David Bureš on 02.04.2022.
//

import SwiftUI

struct UserProfileLink: View {
    var account: SavedAccount
    var user: APIPerson
    var showServerInstance: Bool

    // Extra context about where the link is being displayed
    // to pick the correct flair
    var postContext: APIPostView?
    var commentContext: APIComment?

    var body: some View {
        NavigationLink(value: user) {
            UserProfileLabel(
                account: account,
                user: user,
                showServerInstance: showServerInstance,
                postContext: postContext,
                commentContext: commentContext
            )
        }
    }
}
