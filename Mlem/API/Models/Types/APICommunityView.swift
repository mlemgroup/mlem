//
//  APICommunityView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/CommunityView.ts
struct APICommunityView: Codable {
    let community: APICommunity
    let subscribed: APISubscribedType
    let blocked: Bool
    let counts: APICommunityAggregates

    func toQueryItems() -> [URLQueryItem] {
        [
        ]
    }
}
