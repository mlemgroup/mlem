//
//  APIAdminPurgeComment.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// sources/js/types/AdminPurgeComment.ts
struct APIAdminPurgeComment: Codable {
    // swiftlint:disable:next identifier_name
    let id: Int
    let adminPersonId: Int
    let postId: Int
    let reason: String?
    let when_: String
}
