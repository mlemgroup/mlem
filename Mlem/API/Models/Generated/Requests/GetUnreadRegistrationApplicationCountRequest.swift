//
//  GetUnreadRegistrationApplicationCountRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct GetUnreadRegistrationApplicationCountRequest: APIGetRequest {
    typealias Response = APIGetUnreadRegistrationApplicationCountResponse

    let path = "/admin/registration_application/count"
    let queryItems: [URLQueryItem]

    init() {
        self.queryItems = .init()
    }
}
