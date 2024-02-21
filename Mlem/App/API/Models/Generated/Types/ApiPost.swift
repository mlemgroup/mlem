//
//  ApiPost.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// Post.ts
struct ApiPost: Codable {
    let id: Int
    let name: String
    let url: String?
    let body: String?
    let creatorId: Int
    let communityId: Int
    let removed: Bool
    let locked: Bool
    let published: Date
    let updated: Date?
    let deleted: Bool
    let nsfw: Bool
    let embedTitle: String?
    let embedDescription: String?
    let thumbnailUrl: URL?
    let apId: URL
    let local: Bool
    let embedVideoUrl: URL?
    let languageId: Int
    let featuredCommunity: Bool
    let featuredLocal: Bool
}
