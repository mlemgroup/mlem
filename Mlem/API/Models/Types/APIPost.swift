//
//  APIPost.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/Post.ts
struct APIPost: Codable {
    let id: Int
    let name: String
    let url: String?
    let body: String?
    let creator_id: Int
    let community_id: Int
    let removed: Bool
    let locked: Bool
    let published: String
    let updated: String?
    let deleted: Bool
    let nsfw: Bool
    let embed_title: String?
    let embed_description: String?
    let thumbnail_url: String?
    let ap_id: String
    let local: Bool
    let embed_video_url: String?
    let language_id: Int
    let featured_community: Bool
    let featured_local: Bool

    func toQueryItems() -> [URLQueryItem] {
        [
            .init(name: "id", value: String(id)),
            .init(name: "name", value: name),
            .init(name: "url", value: url),
            .init(name: "body", value: body),
            .init(name: "creator_id", value: String(creator_id)),
            .init(name: "community_id", value: String(community_id)),
            .init(name: "removed", value: String(removed)),
            .init(name: "locked", value: String(locked)),
            .init(name: "published", value: published),
            .init(name: "updated", value: updated),
            .init(name: "deleted", value: String(deleted)),
            .init(name: "nsfw", value: String(nsfw)),
            .init(name: "embed_title", value: embed_title),
            .init(name: "embed_description", value: embed_description),
            .init(name: "thumbnail_url", value: thumbnail_url),
            .init(name: "ap_id", value: ap_id),
            .init(name: "local", value: String(local)),
            .init(name: "embed_video_url", value: embed_video_url),
            .init(name: "language_id", value: String(language_id)),
            .init(name: "featured_community", value: String(featured_community)),
            .init(name: "featured_local", value: String(featured_local))
        ]
    }
}
