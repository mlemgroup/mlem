//
//  APIModRemovePostView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-27
//

import Foundation

// ModRemovePostView.ts
struct APIModRemovePostView: Decodable {
    let modRemovePost: APIModRemovePost
    let moderator: APIPerson?
    let post: APIPost
    let community: APICommunity
}
