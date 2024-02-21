//
//  ApiModHideCommunity.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// ModHideCommunity.ts
struct ApiModHideCommunity: Codable {
    let id: Int
    let communityId: Int
    let modPersonId: Int
    let when_: String
    let reason: String?
    let hidden: Bool
}
