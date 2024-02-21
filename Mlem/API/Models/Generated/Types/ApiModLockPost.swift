//
//  ApiModLockPost.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// ModLockPost.ts
struct ApiModLockPost: Codable {
    let id: Int
    let modPersonId: Int
    let postId: Int
    let locked: Bool
    let when_: String
}
