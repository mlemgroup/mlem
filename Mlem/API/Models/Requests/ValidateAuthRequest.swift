//
//  ValidateAuthRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

struct ValidateAuthRequest: APIGetRequest {
    typealias Response = APISuccessResponse

    let path = "/user/validate_auth"
    let queryItems: [URLQueryItem]

    init() {
        var request: REQUEST_TYPE = BODY_INIT
        self.queryItems = .init()
    }
}
