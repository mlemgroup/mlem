//
//  APIMyUserInfo.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// sources/js/types/MyUserInfo.ts
struct APIMyUserInfo: Codable {
    let localUserView: APILocalUserView
    let follows: [APICommunityFollowerView]
    let moderates: [APICommunityModeratorView]
    let communityBlocks: [APICommunityBlockView]
    let instanceBlocks: [APIInstanceBlockView]
    let personBlocks: [APIPersonBlockView]
    let discussionLanguages: [Int]
}
