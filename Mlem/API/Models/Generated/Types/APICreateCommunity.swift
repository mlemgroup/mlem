//
//  APICreateCommunity.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// ../sources/js/types/CreateCommunity.ts
struct APICreateCommunity: Codable {
    let name: String
    let title: String
    let description: String?
    let icon: URL?
    let banner: URL?
    let nsfw: Bool?
    let postingRestrictedToMods: Bool?
    let discussionLanguages: [Int]?
}
