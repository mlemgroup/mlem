//
//  APIBanPersonResponse.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// sources/js/types/BanPersonResponse.ts
struct APIBanPersonResponse: Codable {
    let person_view: APIPersonView
    let banned: Bool
}
