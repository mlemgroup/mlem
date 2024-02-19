//
//  APIDeleteAccount.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/DeleteAccount.ts
struct APIDeleteAccount: Codable {
    let password: String
    let delete_content: Bool

    func toQueryItems() -> [URLQueryItem] {
        [
            .init(name: "password", value: password),
            .init(name: "delete_content", value: String(delete_content))
        ]
    }
}
