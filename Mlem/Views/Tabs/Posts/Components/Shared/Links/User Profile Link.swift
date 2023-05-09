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
    @AppStorage("shouldShowUserAvatars") var shouldShowUserAvatars: Bool = true
    
    @State var user: User

    var body: some View
    {
        NavigationLink(destination: UserView(user: user))
        {
            HStack(alignment: .center, spacing: 5) {
                if shouldShowUserAvatars
                {
                    if let avatarLink = user.avatarLink
                    {
                        AvatarView(avatarLink: avatarLink)
                    }
                }
                
                Text(user.name)
            }
            .if(user.admin)
            { viewProxy in
                viewProxy
                    .foregroundColor(.red)
            }
            .if(user.bot)
            { viewProxy in
                viewProxy
                    .foregroundColor(.indigo)
            }
            .if(user.name == "lFenix")
            { viewProxy in
                viewProxy
                    .foregroundColor(.yellow)
            }
        }
    }
}
