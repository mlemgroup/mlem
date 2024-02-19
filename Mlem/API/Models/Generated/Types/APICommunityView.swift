//
//  APICommunityView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// ../sources/js/types/CommunityView.ts
struct APICommunityView: Codable {
    let community: APICommunity
    let subscribed: APISubscribedType
    let blocked: Bool
    let counts: APICommunityAggregates
}
