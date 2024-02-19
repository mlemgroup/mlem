//
//  APIModFeaturePost.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// ../sources/js/types/ModFeaturePost.ts
struct APIModFeaturePost: Codable {
    let id: Int
    let modPersonId: Int
    let postId: Int
    let featured: Bool
    let when_: String
    let isFeaturedCommunity: Bool
}
