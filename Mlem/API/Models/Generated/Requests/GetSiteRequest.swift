//
//  GetSiteRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct GetSiteRequest: APIGetRequest {
    typealias Response = APIGetSiteResponse

    let path = "/site"
    let queryItems: [URLQueryItem]

    init() {
        self.queryItems = .init()
    }
}
