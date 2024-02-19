//
//  APITransferCommunity.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/TransferCommunity.ts
struct APITransferCommunity: Codable {
    let community_id: Int
    let person_id: Int

    func toQueryItems() -> [URLQueryItem] {
        [
            .init(name: "community_id", value: String(community_id)),
            .init(name: "person_id", value: String(person_id))
        ]
    }
}
