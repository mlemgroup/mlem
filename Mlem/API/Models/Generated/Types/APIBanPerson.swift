//
//  APIBanPerson.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-20
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// BanPerson.ts
struct APIBanPerson: Codable {
    let personId: Int
    let ban: Bool
    let removeData: Bool?
    let reason: String?
    let expires: Int?
}
