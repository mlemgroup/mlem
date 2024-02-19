//
//  RegisterRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct RegisterRequest: APIPostRequest {
    typealias Body = APIRegister
    typealias Response = APILoginResponse

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
            password_verify: passwordVerify,
            show_nsfw: showNsfw,
            email: email,
            captcha_uuid: captchaUuid,
            captcha_answer: captchaAnswer,
            honeypot: honeypot,
            answer: answer
        )
    }
}
