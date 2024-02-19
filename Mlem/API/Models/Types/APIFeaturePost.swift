//
//  APIFeaturePost.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/FeaturePost.ts
struct APIFeaturePost: Codable {
    let post_id: Int
    let featured: Bool
    let feature_type: APIPostFeatureType

    func toQueryItems() -> [URLQueryItem] {
        [
        ]
    }
}
