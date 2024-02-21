//
//  ApiBanFromCommunity.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// BanFromCommunity.ts
struct ApiBanFromCommunity: Codable {
    let communityId: Int
    let personId: Int
    let ban: Bool
    let removeData: Bool?
    let reason: String?
    let expires: Int?
}
