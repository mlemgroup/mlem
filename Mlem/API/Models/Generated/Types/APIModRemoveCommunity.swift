//
//  APIModRemoveCommunity.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// ../sources/js/types/ModRemoveCommunity.ts
struct APIModRemoveCommunity: Codable {
    let id: Int
    let modPersonId: Int
    let communityId: Int
    let reason: String?
    let removed: Bool
    let when_: String
}
