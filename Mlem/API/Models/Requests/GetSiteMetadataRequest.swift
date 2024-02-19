//
//  GetSiteMetadataRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

struct GetSiteMetadataRequest: APIGetRequest {
    typealias Response = APIGetSiteMetadataResponse

    let path = "/post/site_metadata"
    let queryItems: [URLQueryItem]

    init(
        url: String
    ) {
        var request: APIGetSiteMetadata = .init(
            url: url
        )
        self.queryItems = request.toQueryItems()
    }
}
