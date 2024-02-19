//
//  LoginRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct LoginRequest: APIPostRequest {
    typealias Body = APILogin
    typealias Response = APILoginResponse

    let path = "/user/login"
    let body: Body?

    init(
        usernameOrEmail: String,
        password: String,
        totp2faToken: String?
    ) {
        self.body = .init(
            usernameOrEmail: usernameOrEmail,
            password: password,
            totp2faToken: totp2faToken
        )
    }
}
