//
//  APIPost.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

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
    let published: Date
    let updated: Date?
    let deleted: Bool
    let nsfw: Bool
    let embed_title: String?
    let embed_description: String?
    let thumbnail_url: URL?
    let ap_id: URL
    let local: Bool
    let embed_video_url: URL?
    let language_id: Int
    let featured_community: Bool
    let featured_local: Bool
}
