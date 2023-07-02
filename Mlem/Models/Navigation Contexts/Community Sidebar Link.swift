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
        hasher.combine(self.id)
    }
    
    var id: String { communityDetails?.communityView.community.id.description ?? UUID().uuidString }
    
    let community: APICommunity
    let communityDetails: GetCommunityResponse?
}
