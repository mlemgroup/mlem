//
//  CommunityLinkWithContext.swift
//  Mlem
//
//  Created by tht7 on 23/06/2023.
//

import Foundation
import SwiftUI

struct CommunityLinkWithContext: Equatable, Identifiable, Hashable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.community?.id)
        hasher.combine(self.feedType)
    }
    
    var id: Int { self.hashValue }
    
    let community: APICommunity?
    let feedType: FeedType
}
