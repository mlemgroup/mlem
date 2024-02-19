//
//  APICommunity.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// ../sources/js/types/Community.ts
struct APICommunity: Codable {
    let id: Int
    let name: String
    let title: String
    let description: String?
    let removed: Bool
    let published: Date
    let updated: Date?
    let deleted: Bool
    let nsfw: Bool
    let actorId: URL
    let local: Bool
    let icon: URL?
    let banner: URL?
    let hidden: Bool
    let postingRestrictedToMods: Bool
    let instanceId: Int
}
