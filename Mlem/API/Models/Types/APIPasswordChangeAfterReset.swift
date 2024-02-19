//
//  APIPasswordChangeAfterReset.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/PasswordChangeAfterReset.ts
struct APIPasswordChangeAfterReset: Codable {
    let token: String
    let password: String
    let password_verify: String

    func toQueryItems() -> [URLQueryItem] {
        [
            .init(name: "token", value: token),
            .init(name: "password", value: password),
            .init(name: "password_verify", value: password_verify)
        ]
    }
}
