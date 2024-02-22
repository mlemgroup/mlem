//
//  ApiGetPostsResponse.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// GetPostsResponse.ts
struct ApiGetPostsResponse: Codable {
    let posts: [ApiPostView]
    let nextPage: String?
}
