//
//  ApiModRemovePostView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-27
//

import Foundation

// ModRemovePostView.ts
struct APIModRemovePostView: Decodable {
    let mod_remove_post: APIModRemovePost
    let moderator: APIPerson?
    let post: APIPost
    let community: APICommunity
}
