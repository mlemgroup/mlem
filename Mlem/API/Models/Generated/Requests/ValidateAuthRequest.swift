//
//  ValidateAuthRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct ValidateAuthRequest: APIGetRequest {
    typealias Response = APISuccessResponse

    let path = "/user/validate_auth"
    let queryItems: [URLQueryItem]

    init() {
        self.queryItems = .init()
    }
}
