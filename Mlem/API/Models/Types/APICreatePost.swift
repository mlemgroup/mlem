//
//  APICreatePost.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/CreatePost.ts
struct APICreatePost: Codable {
    let name: String
    let community_id: Int
    let url: String?
    let body: String?
    let honeypot: String?
    let nsfw: Bool?
    let language_id: Int?

    func toQueryItems() -> [URLQueryItem] {
        [
            .init(name: "name", value: name),
            .init(name: "community_id", value: String(community_id)),
            .init(name: "url", value: url),
            .init(name: "body", value: body),
            .init(name: "honeypot", value: honeypot),
            .init(name: "nsfw", value: nsfw.map(String.init)),
            .init(name: "language_id", value: language_id.map(String.init))
        ]
    }
}
