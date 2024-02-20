//
//  APISearchResponse.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-20
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// SearchResponse.ts
struct APISearchResponse: Codable {
    let type_: APISearchType
    let comments: [APICommentView]
    let posts: [APIPostView]
    let communities: [APICommunityView]
    let users: [APIPersonView]
}
