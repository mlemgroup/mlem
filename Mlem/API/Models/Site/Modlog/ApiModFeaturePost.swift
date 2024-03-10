//
//  ApiModFeaturePost.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-27
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// ModFeaturePost.ts
struct ApiModFeaturePost: Codable {
    let id: Int
    let mod_person_id: Int
    let post_id: Int
    let featured: Bool
    let when_: String
    let is_featured_community: Bool
}
