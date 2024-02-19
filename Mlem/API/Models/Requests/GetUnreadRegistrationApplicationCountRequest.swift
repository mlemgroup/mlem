//
//  GetUnreadRegistrationApplicationCountRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

struct GetUnreadRegistrationApplicationCountRequest: APIGetRequest {
    typealias Response = APIGetUnreadRegistrationApplicationCountResponse

    let path = "/admin/registration_application/count"
    let queryItems: [URLQueryItem]

    init() {
        var request: REQUEST_TYPE = BODY_INIT
        self.queryItems = .init()
    }
}
