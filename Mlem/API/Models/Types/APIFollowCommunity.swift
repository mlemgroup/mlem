//
//  APIFollowCommunity.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/FollowCommunity.ts
struct APIFollowCommunity: Codable {
    let community_id: Int
    let follow: Bool

    func toQueryItems() -> [URLQueryItem] {
        [
            .init(name: "community_id", value: String(community_id)),
            .init(name: "follow", value: String(follow))
        ]
    }
}
