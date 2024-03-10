//
//  ApiModFeaturePost.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-27
//

import Foundation

// ModFeaturePost.ts
struct ApiModFeaturePost: Decodable {
    let id: Int
    let modPersonId: Int
    let postId: Int
    let featured: Bool
    let when_: String
    let isFeaturedCommunity: Bool
}
