//
//  Sidebar.swift
//  Mlem
//
//  Created by David Bureš on 08.05.2023.
//

import SwiftUI

struct CommunitySidebarView: View
{
    @State var community: Community
    @Binding var isActive: Bool

    var body: some View
    {
        VStack(alignment: .leading, spacing: 15)
        {
            if community.details != nil
            {
                Text(String(community.details!.numberOfPosts))
            }
            else
            {
                ProgressView
                {
                    Text("Loading details…")
                }
            }
        }
        .onDisappear
        {
            isActive = false
        }
    }
}
