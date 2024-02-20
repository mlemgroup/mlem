//
//  APICreatePost.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-20
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// CreatePost.ts
struct APICreatePost: Codable {
    let name: String
    let communityId: Int
    let url: String?
    let body: String?
    let honeypot: String?
    let nsfw: Bool?
    let languageId: Int?
}
