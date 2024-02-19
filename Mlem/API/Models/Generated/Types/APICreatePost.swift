//
//  APICreatePost.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// sources/js/types/CreatePost.ts
struct APICreatePost: Codable {
    let name: String
    let communityId: Int
    let url: String?
    let body: String?
    let honeypot: String?
    let nsfw: Bool?
    let languageId: Int?
}
