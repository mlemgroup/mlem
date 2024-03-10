//
//  ApiAdminPurgeComment.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-27
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// AdminPurgeComment.ts
struct ApiAdminPurgeComment: Codable {
    let id: Int
    let admin_person_id: Int
    let post_id: Int
    let reason: String?
    let when_: String
}
