//
//  APIRegister.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

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
}
