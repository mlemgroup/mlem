//
//  APIFeaturePost.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// sources/js/types/FeaturePost.ts
struct APIFeaturePost: Codable {
    let post_id: Int
    let featured: Bool
    let feature_type: APIPostFeatureType
}
