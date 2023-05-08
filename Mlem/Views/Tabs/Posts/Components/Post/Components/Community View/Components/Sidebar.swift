//
//  Sidebar.swift
//  Mlem
//
//  Created by David Bureš on 08.05.2023.
//

import SwiftUI

struct CommunitySidebarView: View {
    
    @State var community: Community
    
    var body: some View {
        if community.details != nil
        {
            Text(String(community.details!.numberOfPosts))
        }
        else
        {
            ProgressView {
                Text("Loading details…")
            }
        }

    }
}
