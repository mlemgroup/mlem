//
//  User View.swift
//  Mlem
//
//  Created by David Bureš on 02.04.2022.
//

import SwiftUI

struct UserView: View
{
    @State var userName: String

    var body: some View
    {
        Text("Page for \(userName)")
    }
}
