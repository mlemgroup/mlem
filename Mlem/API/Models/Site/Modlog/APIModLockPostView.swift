//
//  APIModLockPostView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-27
//

import Foundation

// ModLockPostView.ts
struct APIModLockPostView: Decodable {
    let modLockPost: APIModLockPost
    let moderator: APIPerson?
    let post: APIPost
    let community: APICommunity
}
