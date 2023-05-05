//
//  User Profile Link.swift
//  Mlem
//
//  Created by David Bureš on 02.04.2022.
//

import SwiftUI

struct UserProfileLink: View
{
    @State var userName: String

    var body: some View
    {
        NavigationLink(destination: UserView(userName: userName))
        {
            Text(userName)
        }
    }
}
