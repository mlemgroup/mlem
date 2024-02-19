//
//  APILocalSiteRateLimit.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/LocalSiteRateLimit.ts
struct APILocalSiteRateLimit: Codable {
    let local_site_id: Int
    let message: Int
    let message_per_second: Int
    let post: Int
    let post_per_second: Int
    let register: Int
    let register_per_second: Int
    let image: Int
    let image_per_second: Int
    let comment: Int
    let comment_per_second: Int
    let search: Int
    let search_per_second: Int
    let published: String
    let updated: String?
    let import_user_settings: Int
    let import_user_settings_per_second: Int

    func toQueryItems() -> [URLQueryItem] {
        [
            .init(name: "local_site_id", value: String(local_site_id)),
            .init(name: "message", value: String(message)),
            .init(name: "message_per_second", value: String(message_per_second)),
            .init(name: "post", value: String(post)),
            .init(name: "post_per_second", value: String(post_per_second)),
            .init(name: "register", value: String(register)),
            .init(name: "register_per_second", value: String(register_per_second)),
            .init(name: "image", value: String(image)),
            .init(name: "image_per_second", value: String(image_per_second)),
            .init(name: "comment", value: String(comment)),
            .init(name: "comment_per_second", value: String(comment_per_second)),
            .init(name: "search", value: String(search)),
            .init(name: "search_per_second", value: String(search_per_second)),
            .init(name: "published", value: published),
            .init(name: "updated", value: updated),
            .init(name: "import_user_settings", value: String(import_user_settings)),
            .init(name: "import_user_settings_per_second", value: String(import_user_settings_per_second))
        ]
    }
}
