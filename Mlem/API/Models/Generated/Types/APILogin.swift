//
//  APILogin.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// sources/js/types/Login.ts
struct APILogin: Codable {
    let usernameOrEmail: String
    let password: String
    let totp2faToken: String?
}
