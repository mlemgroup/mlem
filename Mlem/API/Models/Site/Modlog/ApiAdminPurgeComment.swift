//
//  ApiAdminPurgeComment.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-27
//

import Foundation

// AdminPurgeComment.ts
struct ApiAdminPurgeComment: Decodable {
    let id: Int
    let adminPersonId: Int
    let postId: Int
    let reason: String?
    let when_: String
}
