//
//  LoginRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct LoginRequest: ApiPostRequest {
    typealias Body = ApiLogin
    typealias Response = ApiLoginResponse

    let path = "user/login"
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
