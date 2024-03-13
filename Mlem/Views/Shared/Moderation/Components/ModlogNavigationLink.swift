//
//  ModlogNavigationLink.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-13.
//

import Foundation
import SwiftUI

struct ModlogNavigationLink: View {
    let instance: URL?
    let community: CommunityModel?
    
    var body: some View {
        NavigationLink(value: AppRoute.modlog(.init(instance: instance, community: community))) {
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
