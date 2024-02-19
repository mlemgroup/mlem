//
//  APICommunityFollowerView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/CommunityFollowerView.ts
struct APICommunityFollowerView: Codable {
    let community: APICommunity
    let follower: APIPerson

    func toQueryItems() -> [URLQueryItem] {
        [
        ]
    }
}
