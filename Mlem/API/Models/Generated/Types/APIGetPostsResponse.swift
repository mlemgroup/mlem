//
//  APIGetPostsResponse.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// sources/js/types/GetPostsResponse.ts
struct APIGetPostsResponse: Codable {
    let posts: [APIPostView]
    let next_page: String?
}
