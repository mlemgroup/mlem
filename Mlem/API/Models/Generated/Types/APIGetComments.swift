//
//  APIGetComments.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-20
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// GetComments.ts
struct APIGetComments: Codable {
    let type_: APIListingType?
    let sort: APICommentSortType?
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
