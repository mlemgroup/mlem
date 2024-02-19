//
//  APIModFeaturePostView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// sources/js/types/ModFeaturePostView.ts
struct APIModFeaturePostView: Codable {
    let modFeaturePost: APIModFeaturePost
    let moderator: APIPerson?
    let post: APIPost
    let community: APICommunity
}
