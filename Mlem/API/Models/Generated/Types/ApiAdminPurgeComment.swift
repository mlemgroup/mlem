//
//  ApiAdminPurgeComment.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// AdminPurgeComment.ts
struct ApiAdminPurgeComment: Codable {
    let id: Int
    let adminPersonId: Int
    let postId: Int
    let reason: String?
    let when_: String
}
