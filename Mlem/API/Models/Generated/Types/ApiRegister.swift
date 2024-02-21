//
//  ApiRegister.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// Register.ts
struct ApiRegister: Codable {
    let username: String
    let password: String
    let passwordVerify: String
    let showNsfw: Bool
    let email: String?
    let captchaUuid: String?
    let captchaAnswer: String?
    let honeypot: String?
    let answer: String?
}
