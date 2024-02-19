//
//  APIImageUpload.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/ImageUpload.ts
struct APIImageUpload: Codable {
    let local_user_id: Int
    let pictrs_alias: String
    let pictrs_delete_token: String
    let published: String

    func toQueryItems() -> [URLQueryItem] {
        [
            .init(name: "local_user_id", value: String(local_user_id)),
            .init(name: "pictrs_alias", value: pictrs_alias),
            .init(name: "pictrs_delete_token", value: pictrs_delete_token),
            .init(name: "published", value: published)
        ]
    }
}
