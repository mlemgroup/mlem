//
//  APIGetPosts.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// ../sources/js/types/GetPosts.ts
struct APIGetPosts: Codable {
    let type_: APIListingType?
    let sort: APISortType?
    let page: Int?
    let limit: Int?
    let communityId: Int?
    let communityName: String?
    let savedOnly: Bool?
    let likedOnly: Bool?
    let dislikedOnly: Bool?
    let pageCursor: String?
}
