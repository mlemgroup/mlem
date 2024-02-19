//
//  GetSiteMetadataRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct GetSiteMetadataRequest: APIGetRequest {
    typealias Response = APIGetSiteMetadataResponse

    let path = "/post/site_metadata"
    let queryItems: [URLQueryItem]

    init(
      url: String
    ) {
        self.queryItems = [
            .init(name: "url", value: "\(url)")
        ]
    }
}
