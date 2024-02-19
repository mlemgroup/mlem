//
//  APIPasswordReset.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/PasswordReset.ts
struct APIPasswordReset: Codable {
    let email: String

    func toQueryItems() -> [URLQueryItem] {
        [
            .init(name: "email", value: email)
        ]
    }
}
