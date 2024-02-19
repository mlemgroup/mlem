//
//  APIGetPostsResponse.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/GetPostsResponse.ts
struct APIGetPostsResponse: Codable {
    let posts: [APIPostView]
    let next_page: String?
}
