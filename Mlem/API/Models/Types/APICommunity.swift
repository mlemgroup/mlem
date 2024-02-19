//
//  APICommunity.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/Community.ts
struct APICommunity: Codable {
    let id: Int
    let name: String
    let title: String
    let description: String?
    let removed: Bool
    let published: String
    let updated: String?
    let deleted: Bool
    let nsfw: Bool
    let actor_id: String
    let local: Bool
    let icon: String?
    let banner: String?
    let hidden: Bool
    let posting_restricted_to_mods: Bool
    let instance_id: Int

    func toQueryItems() -> [URLQueryItem] {
        [
            .init(name: "id", value: String(id)),
            .init(name: "name", value: name),
            .init(name: "title", value: title),
            .init(name: "description", value: description),
            .init(name: "removed", value: String(removed)),
            .init(name: "published", value: published),
            .init(name: "updated", value: updated),
            .init(name: "deleted", value: String(deleted)),
            .init(name: "nsfw", value: String(nsfw)),
            .init(name: "actor_id", value: actor_id),
            .init(name: "local", value: String(local)),
            .init(name: "icon", value: icon),
            .init(name: "banner", value: banner),
            .init(name: "hidden", value: String(hidden)),
            .init(name: "posting_restricted_to_mods", value: String(posting_restricted_to_mods)),
            .init(name: "instance_id", value: String(instance_id))
        ]
    }
}
