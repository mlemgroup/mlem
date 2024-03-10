//
//  ApiAdminPurgeCommunity.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-27
//

import Foundation

// AdminPurgeCommunity.ts
struct ApiAdminPurgeCommunity: Codable {
    let id: Int
    let adminPersonId: Int
    let reason: String?
    let when_: String
}
