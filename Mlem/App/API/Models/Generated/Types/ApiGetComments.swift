//
//  ApiGetComments.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// GetComments.ts
struct ApiGetComments: Codable {
    let type_: ApiListingType?
    let sort: ApiCommentSortType?
    let maxDepth: Int?
    let page: Int?
    let limit: Int?
    let communityId: Int?
    let communityName: String?
    let postId: Int?
    let parentId: Int?
    let savedOnly: Bool?
    let likedOnly: Bool?
    let dislikedOnly: Bool?
}
