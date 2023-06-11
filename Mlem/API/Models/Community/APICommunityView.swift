//
//  APICommunityView.swift
//  Mlem
//
//  Created by Nicholas Lawson on 09/06/2023.
//

import Foundation

struct APICommunityView: Decodable {
    let counts: APICommunityAggregates
    let subscribed: APISubscribedStatus
    let community: APICommunity
}
