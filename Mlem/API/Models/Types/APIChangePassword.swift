//
//  APIChangePassword.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/ChangePassword.ts
struct APIChangePassword: Codable {
    let new_password: String
    let new_password_verify: String
    let old_password: String

    func toQueryItems() -> [URLQueryItem] {
        [
            .init(name: "new_password", value: new_password),
            .init(name: "new_password_verify", value: new_password_verify),
            .init(name: "old_password", value: old_password)
        ]
    }
}
