//
//  RegisterRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct RegisterRequest: ApiPostRequest {
    typealias Body = ApiRegister
    typealias Response = ApiLoginResponse

    let path = "/user/register"
    let body: Body?

    init(
        username: String,
        password: String,
        passwordVerify: String,
        showNsfw: Bool,
        email: String?,
        captchaUuid: String?,
        captchaAnswer: String?,
        honeypot: String?,
        answer: String?
    ) {
        self.body = .init(
            username: username,
            password: password,
            passwordVerify: passwordVerify,
            showNsfw: showNsfw,
            email: email,
            captchaUuid: captchaUuid,
            captchaAnswer: captchaAnswer,
            honeypot: honeypot,
            answer: answer
        )
    }
}
