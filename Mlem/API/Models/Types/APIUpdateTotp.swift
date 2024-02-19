//
//  APIUpdateTotp.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/UpdateTotp.ts
struct APIUpdateTotp: Codable {
    let totp_token: String
    let enabled: Bool

    func toQueryItems() -> [URLQueryItem] {
        return [
            .init(name: "totp_token", value: totp_token),
            .init(name: "enabled", value: String(enabled))
        ]
    }

}
