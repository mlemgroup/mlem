//
//  ModlogLink.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-11.
//

import Foundation

struct ModlogLink: Hashable {
    let community: CommunityModel?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(community)
    }
}
