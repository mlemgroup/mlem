//
//  APILogin.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-20
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// Login.ts
struct APILogin: Codable {
    let usernameOrEmail: String
    let password: String
    let totp2faToken: String?
}
