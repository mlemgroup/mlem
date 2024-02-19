//
//  PasswordChangeAfterResetRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct PasswordChangeAfterResetRequest: APIPostRequest {
    typealias Body = APIPasswordChangeAfterReset
    typealias Response = APISuccessResponse

    let path = "/user/password_change"
    let body: Body?

    init(
        token: String,
        password: String,
        passwordVerify: String
    ) {
        self.body = .init(
            token: token,
            password: password,
            password_verify: passwordVerify
        )
    }
}
