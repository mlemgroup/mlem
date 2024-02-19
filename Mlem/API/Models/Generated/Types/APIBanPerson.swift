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
    let personId: Int
    let ban: Bool
    let removeData: Bool?
    let reason: String?
    let expires: Int?
}
