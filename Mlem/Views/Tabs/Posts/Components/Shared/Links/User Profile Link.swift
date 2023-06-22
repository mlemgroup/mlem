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
    
    static let developerNames = [
        "lemmy.ml/u/lFenix",
        "vlemmy.net/u/darknavi",
        "lemmy.ml/u/BrooklynMan",
        "beehaw.org/u/jojo",
        "sh.itjust.works/u/ericbandrews"
    ]
    
    static let flairDeveloper = UserProfileLinkFlair(color: Color.purple, systemIcon: "hammer.fill")
    static let flairMod = UserProfileLinkFlair(color: Color.green, systemIcon: "shield.fill")
    static let flairBot = UserProfileLinkFlair(color: Color.indigo, systemIcon: "server.rack")
    static let flairOP = UserProfileLinkFlair(color: Color.orange, systemIcon: "person.fill")
    static let flairAdmin = UserProfileLinkFlair(color: Color.red, systemIcon: "crown.fill")
    static let flairRegular = UserProfileLinkFlair(color: Color.gray)
   
    var body: some View
    {
        NavigationLink(destination: UserView(userID: user.id, account: account))
        {
            UserProfileLabel(account: account, user: user, postContext: postContext, commentContext: commentContext)
        }
    }
}
