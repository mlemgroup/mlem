//
//  ApiCommunityView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// CommunityView.ts
struct ApiCommunityView: Codable {
    let community: ApiCommunity
    let subscribed: ApiSubscribedType
    let blocked: Bool
    let counts: ApiCommunityAggregates
}
