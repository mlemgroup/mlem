//
//  APIModFeaturePost.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// sources/js/types/ModFeaturePost.ts
struct APIModFeaturePost: Codable {
    let id: Int
    let mod_person_id: Int
    let post_id: Int
    let featured: Bool
    let when_: String
    let is_featured_community: Bool
}
