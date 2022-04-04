//
//  User Profile Link.swift
//  Mlem
//
//  Created by David Bureš on 02.04.2022.
//

import SwiftUI

struct User_Profile_Link: View {
    let userName: String
    
    var body: some View {
        NavigationLink(destination: User_View(userName: userName)) {
            Text(userName)
        }
    }
}
