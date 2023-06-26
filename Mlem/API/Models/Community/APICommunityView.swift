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

extension APICommunityView: Hashable, Equatable {
    static func == (lhs: APICommunityView, rhs: APICommunityView) -> Bool {
        return lhs.community.id == rhs.community.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.community.id)
    }


}
