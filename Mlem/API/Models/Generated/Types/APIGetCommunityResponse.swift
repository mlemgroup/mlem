//
//  APIGetCommunityResponse.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// sources/js/types/GetCommunityResponse.ts
struct APIGetCommunityResponse: Codable {
    let community_view: APICommunityView
    let site: APISite?
    let moderators: [APICommunityModeratorView]
    let discussion_languages: [Int]
}
