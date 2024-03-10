//
//  ApiModFeaturePostView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-27
//

import Foundation

// ModFeaturePostView.ts
struct ApiModFeaturePostView: Decodable {
    let mod_feature_post: ApiModFeaturePost
    let moderator: APIPerson?
    let post: APIPost
    let community: APICommunity
}
