//
//  FeaturePostRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-25
//

import Foundation

struct FeaturePostRequest: APIPostRequest {
    typealias Response = ApiPostResponse
    
    var instanceURL: URL
    let path = "post/feature"
    let body: Body
    
    struct Body: Encodable {
        let post_id: Int
        let featured: Bool
        let feature_type: String
        let auth: String
    }
    
    init(
        session: APISession,
        postId: Int,
        featured: Bool,
        featureType: ApiPostFeatureType
    ) throws {
        self.instanceURL = try session.instanceUrl
        
        self.body = try .init(
            post_id: postId,
            featured: featured,
            feature_type: featureType.rawValue,
            auth: session.token
        )
    }
}
