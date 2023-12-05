//
//  Community Sidebar Link.swift
//  Mlem
//
//  Created by Jake Shirley on 7/1/23.
//

import Foundation
import SwiftUI

struct CommunitySidebarLinkWithContext: Equatable, Identifiable, Hashable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var id: String { community.communityId.description }
    
    let community: CommunityModel
}
