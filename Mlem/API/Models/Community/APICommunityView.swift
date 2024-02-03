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

extension APICommunityView: APIContentType {
    var contentId: Int { community.id }
}

extension APICommunityView: Hashable, Equatable, Identifiable {
    var id: Int { hashValue }
    
    static func == (lhs: APICommunityView, rhs: APICommunityView) -> Bool {
        lhs.hashValue == rhs.hashValue
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(community.id)
        hasher.combine(subscribed)
        hasher.combine(blocked)
    }
}
