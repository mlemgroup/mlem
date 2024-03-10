//
//  ApiAdminPurgePost.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-27
//

import Foundation

// AdminPurgePost.ts
struct ApiAdminPurgePost: Codable {
    let id: Int
    let adminPersonId: Int
    let communityId: Int
    let reason: String?
    let when_: String
}
