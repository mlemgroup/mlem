//
//  ApiMyUserInfo.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// MyUserInfo.ts
struct ApiMyUserInfo: Codable {
    let localUserView: ApiLocalUserView
    let follows: [ApiCommunityFollowerView]
    let moderates: [ApiCommunityModeratorView]
    let communityBlocks: [ApiCommunityBlockView]
    let instanceBlocks: [ApiInstanceBlockView]?
    let personBlocks: [ApiPersonBlockView]
    let discussionLanguages: [Int]
}
