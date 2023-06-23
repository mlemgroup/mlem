//
//  User Profile Link.swift
//  Mlem
//
//  Created by David Bureš on 02.04.2022.
//

import SwiftUI

struct UserProfileLink: View
{
    @State var account: SavedAccount
    @State var user: APIPerson
    
    // Extra context about where the link is being displayed
    // to pick the correct flair
    @State var postContext: APIPostView? = nil
    @State var commentContext: APIComment? = nil
   
    var body: some View
    {
        NavigationLink(value: user)
        {
            UserProfileLabel(account: account, user: user, postContext: postContext, commentContext: commentContext)
        }
    }
}
