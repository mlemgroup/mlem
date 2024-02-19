//
//  LogoutRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct LogoutRequest: APIPostRequest {
    typealias Body = Int // dummy type for APIRequestBodyProviding conformance
    typealias Response = APISuccessResponse

    let path = "/user/logout"
    let body: Body?

    init() {
        self.body = nil
    }
}
