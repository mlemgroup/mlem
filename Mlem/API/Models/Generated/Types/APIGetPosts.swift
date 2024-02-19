//
//  APIGetPosts.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// sources/js/types/GetPosts.ts
struct APIGetPosts: Codable {
    let type_: APIListingType?
    let sort: APISortType?
    let page: Int?
    let limit: Int?
    let community_id: Int?
    let community_name: String?
    let saved_only: Bool?
    let liked_only: Bool?
    let disliked_only: Bool?
    let page_cursor: String?
}
