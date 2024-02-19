//
//  APIGetPostResponse.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/GetPostResponse.ts
struct APIGetPostResponse: Codable {
    let post_view: APIPostView
    let community_view: APICommunityView
    let moderators: [APICommunityModeratorView]
    let cross_posts: [APIPostView]
}
