//
//  APIRemoveCommunity.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/RemoveCommunity.ts
struct APIRemoveCommunity: Codable {
    let community_id: Int
    let removed: Bool
    let reason: String?

    func toQueryItems() -> [URLQueryItem] {
        [
            .init(name: "community_id", value: String(community_id)),
            .init(name: "removed", value: String(removed)),
            .init(name: "reason", value: reason)
        ]
    }
}
