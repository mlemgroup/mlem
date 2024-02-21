//
//  ApiModRemoveComment.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// ModRemoveComment.ts
struct ApiModRemoveComment: Codable {
    let id: Int
    let modPersonId: Int
    let commentId: Int
    let reason: String?
    let removed: Bool
    let when_: String
}
