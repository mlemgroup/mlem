//
//  APIEditCommunity.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// sources/js/types/EditCommunity.ts
struct APIEditCommunity: Codable {
    let community_id: Int
    let title: String?
    let description: String?
    let icon: URL?
    let banner: URL?
    let nsfw: Bool?
    let posting_restricted_to_mods: Bool?
    let discussion_languages: [Int]?
}
