//
//  APIUpdateTotp.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// sources/js/types/UpdateTotp.ts
struct APIUpdateTotp: Codable {
    let totp_token: String
    let enabled: Bool
}
