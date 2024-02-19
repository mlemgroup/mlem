//
//  APILogin.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/Login.ts
struct APILogin: Codable {
    let username_or_email: String
    let password: String
    let totp_2fa_token: String?

    func toQueryItems() -> [URLQueryItem] {
        [
            .init(name: "username_or_email", value: username_or_email),
            .init(name: "password", value: password),
            .init(name: "totp_2fa_token", value: totp_2fa_token)
        ]
    }
}
