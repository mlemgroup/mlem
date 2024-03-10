//
//  ApiModAddCommunity.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-27
//

import Foundation

// ModAddCommunity.ts
struct ApiModAddCommunity: Codable {
    let id: Int
    let modPersonId: Int
    let otherPersonId: Int
    let communityId: Int
    let removed: Bool
    let when_: String
}
