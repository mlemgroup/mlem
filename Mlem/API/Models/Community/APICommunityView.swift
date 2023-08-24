//
//  APICommunityView.swift
//  Mlem
//
//  Created by Nicholas Lawson on 09/06/2023.
//

import Foundation

// lemmy_db_views_actor::structs::CommunityView
struct APICommunityView: Decodable {
    let community: APICommunity
    let subscribed: APISubscribedStatus
    let blocked: Bool
    let counts: APICommunityAggregates
}

extension APICommunityView: Hashable, Equatable, Identifiable {
    var id: Int { return self.hashValue }
    
    static func == (lhs: APICommunityView, rhs: APICommunityView) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.community.id)
        hasher.combine(self.subscribed)
        hasher.combine(self.blocked)
    }
}
