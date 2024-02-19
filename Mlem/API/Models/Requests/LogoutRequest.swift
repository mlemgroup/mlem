//
//  LogoutRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

struct LogoutRequest: APIPostRequest {
    typealias Response = APISuccessResponse

    let path = "/user/logout"
    let body: Body?

    init() {
        self.body = nil
    }
}
