//
//  ApiModBanFromCommunity.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-25
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// ModBanFromCommunity.ts
struct ApiModBanFromCommunity: Codable {
    let id: Int
    let modPersonId: Int
    let otherPersonId: Int
    let communityId: Int
    let reason: String?
    let banned: Bool
    let expires: String?
    let when_: String
}
