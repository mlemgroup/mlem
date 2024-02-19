//
//  VerifyEmailRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

struct VerifyEmailRequest: APIPostRequest {
    typealias Body = APIVerifyEmail
    typealias Response = APISuccessResponse

    let path = "/user/verify_email"
    let body: Body?

    init(
        token: String
    ) {
        self.body = .init(
            token: token
        )
    }
}
