//
//  ApiLogin.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// Login.ts
struct ApiLogin: Codable {
    let usernameOrEmail: String
    let password: String
    let totp2faToken: String?
}
