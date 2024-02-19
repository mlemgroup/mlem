//
//  APIEditPost.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/EditPost.ts
struct APIEditPost: Codable {
    let post_id: Int
    let name: String?
    let url: String?
    let body: String?
    let nsfw: Bool?
    let language_id: Int?

    func toQueryItems() -> [URLQueryItem] {
        return [
            .init(name: "post_id", value: String(post_id)),
            .init(name: "name", value: name),
            .init(name: "url", value: url),
            .init(name: "body", value: body),
            .init(name: "nsfw", value: nsfw.map(String.init)),
            .init(name: "language_id", value: language_id.map(String.init))
        ]
    }

}
