//
//  APIModFeaturePostView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/ModFeaturePostView.ts
struct APIModFeaturePostView: Codable {
    let mod_feature_post: APIModFeaturePost
    let moderator: APIPerson?
    let post: APIPost
    let community: APICommunity

    func toQueryItems() -> [URLQueryItem] {
        [
        ]
    }
}
