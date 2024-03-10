//
//  ApiModLockPostView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-27
//

import Foundation

// ModLockPostView.ts
struct ApiModLockPostView: Decodable {
    let mod_lock_post: ApiModLockPost
    let moderator: APIPerson?
    let post: APIPost
    let community: APICommunity
}
