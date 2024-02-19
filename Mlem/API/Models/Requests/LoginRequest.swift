//
//  LoginRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

struct LoginRequest: APIPostRequest {
    typealias Body = APILogin
    typealias Response = APILoginResponse

    let path = "/user/login"
    let body: Body?

    init(
        usernameOrEmail: String,
        password: String,
        totp2faToken: String
    ) {
        self.body = .init(
            username_or_email: usernameOrEmail,
            password: password,
            totp_2fa_token: totp2faToken
        )
    }
}
