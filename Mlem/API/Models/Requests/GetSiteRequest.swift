//
//  GetSiteRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

struct GetSiteRequest: APIGetRequest {
    typealias Response = APIGetSiteResponse

    let path = "/site"
    let queryItems: [URLQueryItem]

    init() {
        var request: REQUEST_TYPE = BODY_INIT
        self.queryItems = .init()
    }
}
