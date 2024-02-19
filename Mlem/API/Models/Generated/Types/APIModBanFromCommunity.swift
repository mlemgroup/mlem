//
//  APIModBanFromCommunity.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// ../sources/js/types/ModBanFromCommunity.ts
struct APIModBanFromCommunity: Codable {
    let id: Int
    let modPersonId: Int
    let otherPersonId: Int
    let communityId: Int
    let reason: String?
    let banned: Bool
    let expires: String?
    let when_: String
}
