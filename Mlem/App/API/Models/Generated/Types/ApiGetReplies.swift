//
//  ApiGetReplies.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// GetReplies.ts
struct ApiGetReplies: Codable {
    let sort: ApiCommentSortType?
    let page: Int?
    let limit: Int?
    let unreadOnly: Bool?
}
