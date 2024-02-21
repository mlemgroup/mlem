//
//  ApiModRemoveCommunity.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// ModRemoveCommunity.ts
struct ApiModRemoveCommunity: Codable {
    let id: Int
    let modPersonId: Int
    let communityId: Int
    let reason: String?
    let removed: Bool
    let when_: String
    let expires: String?
}
