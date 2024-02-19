//
//  APIRegister.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/Register.ts
struct APIRegister: Codable {
    let username: String
    let password: String
    let password_verify: String
    let show_nsfw: Bool
    let email: String?
    let captcha_uuid: String?
    let captcha_answer: String?
    let honeypot: String?
    let answer: String?

    func toQueryItems() -> [URLQueryItem] {
        [
            .init(name: "username", value: username),
            .init(name: "password", value: password),
            .init(name: "password_verify", value: password_verify),
            .init(name: "show_nsfw", value: String(show_nsfw)),
            .init(name: "email", value: email),
            .init(name: "captcha_uuid", value: captcha_uuid),
            .init(name: "captcha_answer", value: captcha_answer),
            .init(name: "honeypot", value: honeypot),
            .init(name: "answer", value: answer)
        ]
    }
}
