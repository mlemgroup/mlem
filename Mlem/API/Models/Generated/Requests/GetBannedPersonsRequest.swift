//
//  GetBannedPersonsRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct GetBannedPersonsRequest: APIGetRequest {
    typealias Response = APIBannedPersonsResponse

    let path = "/user/banned"
    let queryItems: [URLQueryItem]

    init() {
        self.queryItems = .init()
    }
}
