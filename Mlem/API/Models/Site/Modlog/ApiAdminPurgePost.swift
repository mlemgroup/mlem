//
//  ApiAdminPurgePost.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-27
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// AdminPurgePost.ts
struct ApiAdminPurgePost: Codable {
    let id: Int
    let admin_person_id: Int
    let community_id: Int
    let reason: String?
    let when_: String
}
