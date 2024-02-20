//
//  APIGetPostsResponse.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-20
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// GetPostsResponse.ts
struct APIGetPostsResponse: Codable {
    let posts: [APIPostView]
    let nextPage: String?
}
