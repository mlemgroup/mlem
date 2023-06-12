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
