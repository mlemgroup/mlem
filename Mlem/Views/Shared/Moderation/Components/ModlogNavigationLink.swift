//
//  ModlogNavigationLink.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-13.
//

import Foundation
import SwiftUI

struct ModlogNavigationLink: View {
    let link: ModlogLink
    
    init() {
        self.link = .userInstance
    }
    
    init(to instance: URL) {
        self.link = .instance(instance)
    }
    
    init(to community: CommunityModel) {
        self.link = .community(community)
    }
    
    var body: some View {
        NavigationLink(value: AppRoute.modlog(link)) {
            HStack(alignment: .center) {
                Text("View Modlog")
                
                Spacer()
                
                Image(systemName: Icons.forward)
                    .imageScale(.small)
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .foregroundColor(.secondary)
        }
    }
}
