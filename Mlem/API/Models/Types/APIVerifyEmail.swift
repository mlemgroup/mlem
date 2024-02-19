//
//  APIVerifyEmail.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/VerifyEmail.ts
struct APIVerifyEmail: Codable {
    let token: String

    func toQueryItems() -> [URLQueryItem] {
        [
            .init(name: "token", value: token)
        ]
    }
}
