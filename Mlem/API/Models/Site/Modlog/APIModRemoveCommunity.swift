//
//  APIModRemoveCommunity.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-27
//

import Foundation

// ModRemoveCommunity.ts
struct APIModRemoveCommunity: Codable {
    let id: Int
    let modPersonId: Int
    let communityId: Int
    let reason: String?
    let removed: Bool
    let expires: String?
    let when_: Date
}
