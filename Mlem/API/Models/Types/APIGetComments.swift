//
//  APIGetComments.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/GetComments.ts
struct APIGetComments: Codable {
    let type_: APIListingType?
    let sort: APICommentSortType?
    let max_depth: Int?
    let page: Int?
    let limit: Int?
    let community_id: Int?
    let community_name: String?
    let post_id: Int?
    let parent_id: Int?
    let saved_only: Bool?
    let liked_only: Bool?
    let disliked_only: Bool?

    func toQueryItems() -> [URLQueryItem] {
        [
        ]
    }
}
