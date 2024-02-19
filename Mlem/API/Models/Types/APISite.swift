//
//  APISite.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/Site.ts
struct APISite: Codable {
    let id: Int
    let name: String
    let sidebar: String?
    let published: String
    let updated: String?
    let icon: String?
    let banner: String?
    let description: String?
    let actor_id: String
    let last_refreshed_at: String
    let inbox_url: String
    let private_key: String?
    let public_key: String
    let instance_id: Int

    func toQueryItems() -> [URLQueryItem] {
        [
            .init(name: "id", value: String(id)),
            .init(name: "name", value: name),
            .init(name: "sidebar", value: sidebar),
            .init(name: "published", value: published),
            .init(name: "updated", value: updated),
            .init(name: "icon", value: icon),
            .init(name: "banner", value: banner),
            .init(name: "description", value: description),
            .init(name: "actor_id", value: actor_id),
            .init(name: "last_refreshed_at", value: last_refreshed_at),
            .init(name: "inbox_url", value: inbox_url),
            .init(name: "private_key", value: private_key),
            .init(name: "public_key", value: public_key),
            .init(name: "instance_id", value: String(instance_id))
        ]
    }
}
