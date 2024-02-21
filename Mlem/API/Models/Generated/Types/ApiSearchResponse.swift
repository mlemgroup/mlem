//
//  ApiSearchResponse.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// SearchResponse.ts
struct ApiSearchResponse: Codable {
    let type_: ApiSearchType
    let comments: [ApiCommentView]
    let posts: [ApiPostView]
    let communities: [ApiCommunityView]
    let users: [ApiPersonView]
}
