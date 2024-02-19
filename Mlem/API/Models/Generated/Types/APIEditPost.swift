//
//  APIEditPost.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// sources/js/types/EditPost.ts
struct APIEditPost: Codable {
    let post_id: Int
    let name: String?
    let url: String?
    let body: String?
    let nsfw: Bool?
    let language_id: Int?
}
