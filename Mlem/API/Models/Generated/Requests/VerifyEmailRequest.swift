//
//  VerifyEmailRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-20
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

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
