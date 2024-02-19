//
//  APIPerson.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/Person.ts
struct APIPerson: Codable {
    let id: Int
    let name: String
    let display_name: String?
    let avatar: String?
    let banned: Bool
    let published: String
    let updated: String?
    let actor_id: String
    let bio: String?
    let local: Bool
    let banner: String?
    let deleted: Bool
    let matrix_user_id: String?
    let bot_account: Bool
    let ban_expires: String?
    let instance_id: Int

    func toQueryItems() -> [URLQueryItem] {
        [
            .init(name: "id", value: String(id)),
            .init(name: "name", value: name),
            .init(name: "display_name", value: display_name),
            .init(name: "avatar", value: avatar),
            .init(name: "banned", value: String(banned)),
            .init(name: "published", value: published),
            .init(name: "updated", value: updated),
            .init(name: "actor_id", value: actor_id),
            .init(name: "bio", value: bio),
            .init(name: "local", value: String(local)),
            .init(name: "banner", value: banner),
            .init(name: "deleted", value: String(deleted)),
            .init(name: "matrix_user_id", value: matrix_user_id),
            .init(name: "bot_account", value: String(bot_account)),
            .init(name: "ban_expires", value: ban_expires),
            .init(name: "instance_id", value: String(instance_id))
        ]
    }
}
