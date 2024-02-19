//
//  APIEditCommunity.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/EditCommunity.ts
struct APIEditCommunity: Codable {
    let community_id: Int
    let title: String?
    let description: String?
    let icon: String?
    let banner: String?
    let nsfw: Bool?
    let posting_restricted_to_mods: Bool?
    let discussion_languages: [Int]?

    func toQueryItems() -> [URLQueryItem] {
        [
        ]
    }
}
