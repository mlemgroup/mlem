//
//  APIBanPerson.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// sources/js/types/BanPerson.ts
struct APIBanPerson: Codable {
    let person_id: Int
    let ban: Bool
    let remove_data: Bool?
    let reason: String?
    let expires: Int?
}
