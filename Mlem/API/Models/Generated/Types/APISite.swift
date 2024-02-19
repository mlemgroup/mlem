//
//  APISite.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// sources/js/types/Site.ts
struct APISite: Codable {
    let id: Int
    let name: String
    let sidebar: String?
    let published: Date
    let updated: Date?
    let icon: URL?
    let banner: URL?
    let description: String?
    let actor_id: URL
    let last_refreshed_at: Date
    let inbox_url: String
    let private_key: String?
    let public_key: String
    let instance_id: Int
}
