//
//  APIModRemoveCommunity.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-20
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// ModRemoveCommunity.ts
struct APIModRemoveCommunity: Codable {
    let id: Int
    let modPersonId: Int
    let communityId: Int
    let reason: String?
    let removed: Bool
    let when_: String
    let expires: String?
}
