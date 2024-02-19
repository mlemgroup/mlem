//
//  APIGetCommunityResponse.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// ../sources/js/types/GetCommunityResponse.ts
struct APIGetCommunityResponse: Codable {
    let communityView: APICommunityView
    let site: APISite?
    let moderators: [APICommunityModeratorView]
    let discussionLanguages: [Int]
}
