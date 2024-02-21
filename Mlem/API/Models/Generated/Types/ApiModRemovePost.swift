//
//  ApiModRemovePost.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// ModRemovePost.ts
struct ApiModRemovePost: Codable {
    let id: Int
    let modPersonId: Int
    let postId: Int
    let reason: String?
    let removed: Bool
    let when_: String
}
