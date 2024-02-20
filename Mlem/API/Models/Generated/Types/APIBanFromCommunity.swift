//
//  APIBanFromCommunity.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-20
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// BanFromCommunity.ts
struct APIBanFromCommunity: Codable {
    let communityId: Int
    let personId: Int
    let ban: Bool
    let removeData: Bool?
    let reason: String?
    let expires: Int?
}
