//
//  APIGetPostResponse.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-20
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// GetPostResponse.ts
struct APIGetPostResponse: Codable {
    let postView: APIPostView
    let communityView: APICommunityView
    let moderators: [APICommunityModeratorView]
    let crossPosts: [APIPostView]
}
