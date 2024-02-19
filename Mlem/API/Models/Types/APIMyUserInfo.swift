//
//  APIMyUserInfo.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/MyUserInfo.ts
struct APIMyUserInfo: Codable {
    let local_user_view: APILocalUserView
    let follows: [APICommunityFollowerView]
    let moderates: [APICommunityModeratorView]
    let community_blocks: [APICommunityBlockView]
    let instance_blocks: [APIInstanceBlockView]
    let person_blocks: [APIPersonBlockView]
    let discussion_languages: [Int]

    func toQueryItems() -> [URLQueryItem] {
        [
        ]
    }
}
