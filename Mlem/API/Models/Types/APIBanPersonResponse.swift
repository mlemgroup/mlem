//
//  APIBanPersonResponse.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/BanPersonResponse.ts
struct APIBanPersonResponse: Codable {
    let person_view: APIPersonView
    let banned: Bool
}
