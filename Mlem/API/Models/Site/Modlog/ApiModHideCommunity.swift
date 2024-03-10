//
//  APIModHideCommunity.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-27
//

import Foundation

// ModHideCommunity.ts
struct APIModHideCommunity: Codable {
    let id: Int
    let communityId: Int
    let modPersonId: Int
    let when_: String
    let reason: String?
    let hidden: Bool
}
