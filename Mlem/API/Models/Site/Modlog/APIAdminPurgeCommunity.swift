//
//  APIAdminPurgeCommunity.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-27
//

import Foundation

// AdminPurgeCommunity.ts
struct APIAdminPurgeCommunity: Decodable {
    let id: Int
    let adminPersonId: Int
    let reason: String?
    let when_: String
}
