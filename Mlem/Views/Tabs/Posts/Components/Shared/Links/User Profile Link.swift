//
//  User Profile Link.swift
//  Mlem
//
//  Created by David Bureš on 02.04.2022.
//

import SwiftUI
import CachedAsyncImage

struct UserProfileLink: View
{
    @State var user: User

    var body: some View
    {
        NavigationLink(destination: UserView(user: user))
        {
            HStack(alignment: .center, spacing: 5) {
                if let avatarLink = user.avatarLink
                {
                    AvatarView(avatarLink: avatarLink)
                }
                
                Text(user.name)
            }
        }
    }
}
