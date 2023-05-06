//
//  User View.swift
//  Mlem
//
//  Created by David Bureš on 02.04.2022.
//

import SwiftUI

struct UserView: View
{
    @State var user: User

    var body: some View
    {
        Text("Page for \(user.name)")
    }
}
