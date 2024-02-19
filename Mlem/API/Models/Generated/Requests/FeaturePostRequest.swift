//
//  FeaturePostRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct FeaturePostRequest: APIPostRequest {
    typealias Body = APIFeaturePost
    typealias Response = APIPostResponse

    let path = "/post/feature"
    let body: Body?

    init(
        postId: Int,
        featured: Bool,
        featureType: APIPostFeatureType
    ) {
        self.body = .init(
            post_id: postId,
            featured: featured,
            feature_type: featureType
        )
    }
}
