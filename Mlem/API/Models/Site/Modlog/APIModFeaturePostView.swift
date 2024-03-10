//
//  APIModFeaturePostView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-27
//

import Foundation

// ModFeaturePostView.ts
struct APIModFeaturePostView: Decodable {
    let modFeaturePost: APIModFeaturePost
    let moderator: APIPerson?
    let post: APIPost
    let community: APICommunity
}
