//
//  ApiGetCommunityResponse.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// GetCommunityResponse.ts
struct ApiGetCommunityResponse: Codable {
    let communityView: ApiCommunityView
    let site: ApiSite?
    let moderators: [ApiCommunityModeratorView]
    let discussionLanguages: [Int]
}
