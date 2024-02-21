//
//  ApiGetPosts.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// GetPosts.ts
struct ApiGetPosts: Codable {
    let type_: ApiListingType?
    let sort: ApiSortType?
    let page: Int?
    let limit: Int?
    let communityId: Int?
    let communityName: String?
    let savedOnly: Bool?
    let likedOnly: Bool?
    let dislikedOnly: Bool?
    let pageCursor: String?
}
