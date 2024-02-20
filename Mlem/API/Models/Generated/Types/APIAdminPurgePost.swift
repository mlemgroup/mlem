//
//  APIAdminPurgePost.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-20
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// AdminPurgePost.ts
struct APIAdminPurgePost: Codable {
    let id: Int
    let adminPersonId: Int
    let communityId: Int
    let reason: String?
    let when_: String
}
