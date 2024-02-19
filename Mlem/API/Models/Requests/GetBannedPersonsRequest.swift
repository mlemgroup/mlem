//
//  GetBannedPersonsRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

struct GetBannedPersonsRequest: APIGetRequest {
    typealias Response = APIBannedPersonsResponse

    let path = "/user/banned"
    let queryItems: [URLQueryItem]

    init() {
        var request: REQUEST_TYPE = BODY_INIT
        self.queryItems = .init()
    }
}
